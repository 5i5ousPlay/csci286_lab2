// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ElectronicMedicalRecord {
    address public clinicAdmin;

    enum SEX {MALE, FEMALE, OTHER}

    struct Patient {
        string name;
        uint age;
        SEX sex;
        string bloodtype;
    }

    mapping(address => Patient) public patients;
    mapping(address => bool) public patientExists;

    mapping(address => mapping(address => bool)) public hasPatientAccess;

    modifier onlyClinicAdmin() {
        require(msg.sender == clinicAdmin,
            "This action is restricted to Clinic Admins only."
        );
        _;
    }

    modifier onlyClinicAdminOrPatient (address _patient) {
        require(
            msg.sender == clinicAdmin || msg.sender == _patient,
            "Only the Clinic Admin or the Patient can perform this action."
        );
        _;
    }

    constructor () {
        clinicAdmin = msg.sender;
    }

    event PatientAdded(address indexed _patient, string name, uint age, SEX sex, string bloodtype);

    function addPatient(address _patient, string memory name, 
                        uint age, SEX sex, string memory bloodtype) 
                        public onlyClinicAdmin {
        require(!patientExists[_patient], "Patient already exists.");

        patients[_patient] = Patient(name, age, sex, bloodtype);
        patientExists[_patient] = true;

        emit PatientAdded(_patient, name, age, sex, bloodtype);
    }

    function getPatient(address _patient) 
            public view returns (string memory name, uint age, SEX sex, string memory bloodtype){
        require(
            msg.sender == clinicAdmin ||
            msg.sender == _patient ||
            hasPatientAccess[msg.sender][_patient],
            "Access denied: User is not authorized to view this record."
        );

        require(patientExists[_patient], "Patient does not exist.");

        Patient memory p = patients[_patient];
        return (p.name, p.age, p.sex, p.bloodtype);
    }

    function grantPatientDoctorAccess(address _doctor, address _patient) 
            public onlyClinicAdminOrPatient(_patient){
        require(patientExists[_patient], "Patient does not exist ");
        hasPatientAccess[_doctor][_patient] = true;
    }

    function revokePatientDoctorAccess(address _doctor, address _patient) 
            public onlyClinicAdminOrPatient(_patient) {
        require(patientExists[_patient], "Patient does not exist ");
        hasPatientAccess[_doctor][_patient] = false;
    }

    function hasPatientRecordAccess(address _doctor, address _patient) public view returns (bool){
        return hasPatientAccess[_doctor][_patient];
    }
}