# Smart Quarantine Management System

A comprehensive blockchain-based system for managing quarantine and isolation protocols during health emergencies, built on the Stacks blockchain using Clarity smart contracts.

## Overview

This system consists of five interconnected smart contracts that work together to create a transparent, secure, and efficient quarantine management system:

1. **Health Monitoring Contract** - Tracks symptoms and test results during isolation
2. **Contact Tracing Contract** - Identifies potential disease exposure chains
3. **Supply Delivery Contract** - Coordinates food and medical deliveries to quarantined individuals
4. **Compliance Verification Contract** - Ensures quarantine rules are followed
5. **Release Authorization Contract** - Determines when isolation can safely end

## Key Features

### Health Monitoring
- Track daily symptom reports from quarantined individuals
- Record test results and medical assessments
- Monitor health status progression over time
- Generate health alerts for deteriorating conditions
- Maintain secure medical data with privacy controls

### Contact Tracing
- Map exposure chains and potential transmission paths
- Track close contacts and their risk levels
- Coordinate testing schedules for exposed individuals
- Generate contact notifications and recommendations
- Maintain privacy while enabling effective tracing

### Supply Delivery
- Coordinate essential supply deliveries to quarantined individuals
- Track delivery status and completion
- Manage delivery personnel assignments and schedules
- Handle special medical supply requests
- Ensure contactless delivery protocols

### Compliance Verification
- Monitor quarantine location compliance
- Track check-in requirements and violations
- Generate compliance reports and alerts
- Coordinate with enforcement when necessary
- Maintain audit trails for legal compliance

### Release Authorization
- Evaluate health criteria for quarantine release
- Process medical clearances and test requirements
- Generate release certificates and documentation
- Coordinate with health authorities for approvals
- Ensure safe transition back to normal activities

## Architecture

Each contract is designed to be independent while supporting the overall quarantine management ecosystem. The system uses:

- **Principal-based Identity**: Secure identification of individuals, health workers, and authorities
- **Privacy Protection**: Sensitive health data with appropriate access controls
- **Immutable Records**: Tamper-proof logging of all quarantine activities
- **Real-time Monitoring**: Continuous tracking of health status and compliance
- **Automated Workflows**: Smart contract automation for routine processes

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for deployment

### Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd smart-quarantine-management

# Install dependencies
npm install

# Run tests
npm test

# Deploy contracts (testnet)
clarinet deploy --testnet
\`\`\`

### Testing

The system includes comprehensive tests for all contracts:

\`\`\`bash
# Run all tests
npm test

# Run specific contract tests
npm test -- health-monitoring
npm test -- contact-tracing
npm test -- supply-delivery
npm test -- compliance-verification
npm test -- release-authorization
\`\`\`

## Contract Specifications

### Data Types

#### Health Data
- Individual ID (principal)
- Symptom reports (daily entries)
- Test results with timestamps
- Health status classifications
- Medical assessments and notes

#### Contact Data
- Contact ID (uint)
- Exposure events with locations and times
- Risk level assessments
- Contact notification status
- Testing recommendations

#### Supply Data
- Delivery ID (uint)
- Recipient information
- Supply type and quantities
- Delivery status and timestamps
- Delivery personnel assignments

#### Compliance Data
- Check-in records with timestamps
- Location verification data
- Violation reports and responses
- Compliance scoring metrics
- Enforcement actions taken

#### Release Data
- Release request ID (uint)
- Health clearance requirements
- Test result validations
- Authority approvals
- Release certificate generation

## Usage Examples

### Recording Health Status
\`\`\`clarity
;; Report daily symptoms
(contract-call? .health-monitoring report-symptoms "fever,cough" u3 "Mild symptoms")

;; Record test result
(contract-call? .health-monitoring record-test-result "PCR" "Negative" u123456789)
\`\`\`

### Contact Tracing
\`\`\`clarity
;; Report exposure event
(contract-call? .contact-tracing report-exposure 'SP1ABC...DEF {lat: 1000, lon: 2000} u123456789 u4)

;; Update contact risk level
(contract-call? .contact-tracing update-risk-level u1 u3)
\`\`\`

### Supply Delivery
\`\`\`clarity
;; Request supply delivery
(contract-call? .supply-delivery request-delivery "Food package" u5 "Urgent")

;; Update delivery status
(contract-call? .supply-delivery update-delivery-status u1 "In transit")
\`\`\`

### Compliance Verification
\`\`\`clarity
;; Record location check-in
(contract-call? .compliance-verification record-checkin {lat: 1000, lon: 2000})

;; Report compliance violation
(contract-call? .compliance-verification report-violation "Left quarantine location" u4)
\`\`\`

### Release Authorization
\`\`\`clarity
;; Request quarantine release
(contract-call? .release-authorization request-release "Completed 14-day isolation")

;; Approve release request
(contract-call? .release-authorization approve-release u1)
\`\`\`

## Error Codes

Each contract defines specific error codes for different failure scenarios:

- ERR-NOT-AUTHORIZED (u100)
- ERR-INVALID-INPUT (u101)
- ERR-NOT-FOUND (u102)
- ERR-ALREADY-EXISTS (u103)
- ERR-INSUFFICIENT-CLEARANCE (u104)
- ERR-QUARANTINE-VIOLATION (u105)

## Privacy and Security

### Data Protection
- Health data encrypted and access-controlled
- Personal information protected with privacy controls
- Audit trails for all data access and modifications
- Compliance with health data protection regulations

### Access Control
- Role-based permissions for different user types
- Multi-signature requirements for sensitive operations
- Time-based access controls for temporary permissions
- Emergency override capabilities for health authorities

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add comprehensive tests
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support, please open an issue in the GitHub repository.
