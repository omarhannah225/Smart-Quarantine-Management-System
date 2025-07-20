;; Health Monitoring Contract
;; Tracks symptoms and test results during isolation

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))

;; Data Variables
(define-data-var report-counter uint u0)
(define-data-var contract-owner principal tx-sender)

;; Data Maps
(define-map health-records
  principal
  {
    quarantine-start: uint,
    current-status: (string-utf8 20),
    last-updated: uint,
    assigned-monitor: (optional principal),
    risk-level: uint
  }
)

(define-map symptom-reports
  {individual: principal, report-id: uint}
  {
    symptoms: (string-utf8 200),
    severity: uint,
    temperature: (optional uint),
    notes: (string-utf8 300),
    timestamp: uint,
    reported-by: principal
  }
)

(define-map test-results
  {individual: principal, test-id: uint}
  {
    test-type: (string-utf8 50),
    result: (string-utf8 20),
    test-date: uint,
    lab-id: (string-utf8 50),
    verified-by: principal,
    notes: (string-utf8 200)
  }
)

(define-map daily-assessments
  {individual: principal, date: uint}
  {
    overall-status: (string-utf8 20),
    symptoms-present: bool,
    requires-medical-attention: bool,
    assessment-notes: (string-utf8 300),
    assessed-by: principal
  }
)

(define-map authorized-monitors principal bool)
(define-map medical-staff principal bool)

;; Authorization Functions
(define-public (add-authorized-monitor (monitor principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-monitors monitor true))
  )
)

(define-public (add-medical-staff (staff principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (map-set medical-staff staff true))
  )
)

;; Health Record Management
(define-public (create-health-record (individual principal) (risk-level uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get contract-owner))
                  (default-to false (map-get? authorized-monitors tx-sender))) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= risk-level u1) (<= risk-level u5)) ERR-INVALID-INPUT)
    (asserts! (is-none (map-get? health-records individual)) ERR-ALREADY-EXISTS)
    (map-set health-records
      individual
      {
        quarantine-start: block-height,
        current-status: u"Active",
        last-updated: block-height,
        assigned-monitor: (some tx-sender),
        risk-level: risk-level
      }
    )
    (ok true)
  )
)

(define-public (update-health-status (individual principal) (new-status (string-utf8 20)))
  (let ((health-data (unwrap! (map-get? health-records individual) ERR-NOT-FOUND)))
    (begin
      (asserts! (or (is-eq tx-sender (var-get contract-owner))
                    (default-to false (map-get? authorized-monitors tx-sender))
                    (default-to false (map-get? medical-staff tx-sender))) ERR-NOT-AUTHORIZED)
      (asserts! (> (len new-status) u0) ERR-INVALID-INPUT)
      (map-set health-records
        individual
        (merge health-data {
          current-status: new-status,
          last-updated: block-height
        })
      )
      (ok true)
    )
  )
)

;; Symptom Reporting
(define-public (report-symptoms (symptoms (string-utf8 200)) (severity uint) (notes (string-utf8 300)))
  (let ((report-id (+ (var-get report-counter) u1)))
    (begin
      (asserts! (is-some (map-get? health-records tx-sender)) ERR-NOT-FOUND)
      (asserts! (and (>= severity u1) (<= severity u5)) ERR-INVALID-INPUT)
      (asserts! (> (len symptoms) u0) ERR-INVALID-INPUT)
      (map-set symptom-reports
        {individual: tx-sender, report-id: report-id}
        {
          symptoms: symptoms,
          severity: severity,
          temperature: none,
          notes: notes,
          timestamp: block-height,
          reported-by: tx-sender
        }
      )
      (var-set report-counter report-id)
      (ok report-id)
    )
  )
)

(define-public (report-symptoms-with-temperature (symptoms (string-utf8 200)) (severity uint) (temperature uint) (notes (string-utf8 300)))
  (let ((report-id (+ (var-get report-counter) u1)))
    (begin
      (asserts! (is-some (map-get? health-records tx-sender)) ERR-NOT-FOUND)
      (asserts! (and (>= severity u1) (<= severity u5)) ERR-INVALID-INPUT)
      (asserts! (and (>= temperature u950) (<= temperature u1100)) ERR-INVALID-INPUT) ;; 95.0F to 110.0F
      (map-set symptom-reports
        {individual: tx-sender, report-id: report-id}
        {
          symptoms: symptoms,
          severity: severity,
          temperature: (some temperature),
          notes: notes,
          timestamp: block-height,
          reported-by: tx-sender
        }
      )
      (var-set report-counter report-id)
      (ok report-id)
    )
  )
)

;; Test Result Recording
(define-public (record-test-result (individual principal) (test-type (string-utf8 50)) (result (string-utf8 20)) (test-date uint) (lab-id (string-utf8 50)) (notes (string-utf8 200)))
  (let ((test-id (+ (var-get report-counter) u1)))
    (begin
      (asserts! (or (is-eq tx-sender (var-get contract-owner))
                    (default-to false (map-get? medical-staff tx-sender))) ERR-NOT-AUTHORIZED)
      (asserts! (is-some (map-get? health-records individual)) ERR-NOT-FOUND)
      (asserts! (> (len test-type) u0) ERR-INVALID-INPUT)
      (asserts! (> (len result) u0) ERR-INVALID-INPUT)
      (map-set test-results
        {individual: individual, test-id: test-id}
        {
          test-type: test-type,
          result: result,
          test-date: test-date,
          lab-id: lab-id,
          verified-by: tx-sender,
          notes: notes
        }
      )
      (var-set report-counter test-id)
      (ok test-id)
    )
  )
)

;; Daily Assessment
(define-public (record-daily-assessment (individual principal) (overall-status (string-utf8 20)) (symptoms-present bool) (requires-attention bool) (assessment-notes (string-utf8 300)))
  (let ((today (/ block-height u144))) ;; Approximate daily blocks
    (begin
      (asserts! (or (is-eq tx-sender (var-get contract-owner))
                    (default-to false (map-get? authorized-monitors tx-sender))
                    (default-to false (map-get? medical-staff tx-sender))) ERR-NOT-AUTHORIZED)
      (asserts! (is-some (map-get? health-records individual)) ERR-NOT-FOUND)
      (map-set daily-assessments
        {individual: individual, date: today}
        {
          overall-status: overall-status,
          symptoms-present: symptoms-present,
          requires-medical-attention: requires-attention,
          assessment-notes: assessment-notes,
          assessed-by: tx-sender
        }
      )
      (ok true)
    )
  )
)

;; Read-only Functions
(define-read-only (get-health-record (individual principal))
  (map-get? health-records individual)
)

(define-read-only (get-symptom-report (individual principal) (report-id uint))
  (map-get? symptom-reports {individual: individual, report-id: report-id})
)

(define-read-only (get-test-result (individual principal) (test-id uint))
  (map-get? test-results {individual: individual, test-id: test-id})
)

(define-read-only (get-daily-assessment (individual principal) (date uint))
  (map-get? daily-assessments {individual: individual, date: date})
)

(define-read-only (get-report-counter)
  (var-get report-counter)
)

(define-read-only (is-authorized-monitor (monitor principal))
  (default-to false (map-get? authorized-monitors monitor))
)

(define-read-only (is-medical-staff (staff principal))
  (default-to false (map-get? medical-staff staff))
)

(define-read-only (requires-immediate-attention (individual principal))
  (let ((health-data (map-get? health-records individual)))
    (match health-data
      record (>= (get risk-level record) u4)
      false
    )
  )
)

(define-read-only (has-recent-symptoms (individual principal))
  (let ((today (/ block-height u144)))
    (match (map-get? daily-assessments {individual: individual, date: today})
      assessment (get symptoms-present assessment)
      false
    )
  )
)
