// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract RizalLibrary {
    address public librarian;
    uint public constant BORROW_DURATION = 14 days;
    uint public constant DEFAULT_FINE = 50000 wei;


    struct Student {
        bool enrolled;
        bool has_borrowed;
        uint borrowed_at;
        string current_book;
        bool has_hold_order;
        uint balance;
    }

    mapping(address => Student) public students;

    modifier onlyLibrarian() {
        require(msg.sender == librarian, "Only a librarian can perform this operation.");
        _;
    }

    modifier onlyEnrolled() {
        require(students[msg.sender].enrolled == true, "Only enrolled students can perform this operation.");
        _;
    }

    modifier noHoldOrder() {
        require(students[msg.sender].has_hold_order == false, "Only students without hold orders can perform this operation.");
        _;
    }
    
    modifier hasHoldOrder() {
        require(students[msg.sender].has_hold_order == true, "Only students with hold orders can perform this operation.");
        _;
    }
    
    function isOverdue() public onlyEnrolled view returns (bool) {
        return (2 minutes < block.timestamp - students[msg.sender].borrowed_at);
    }

    constructor() {
        librarian = msg.sender;
    }

    function addStudent(address _student) public onlyLibrarian {
        students[_student].enrolled = true;
    }

    function borrow(string memory _callNumber) public onlyEnrolled noHoldOrder {
        Student storage s = students[msg.sender];
        require(!s.has_borrowed, "You have already borrowed a book.");

        s.has_borrowed = true;
        s.borrowed_at = block.timestamp;
        s.current_book = _callNumber;
    }

    function returnBook() public onlyEnrolled {
        Student storage s = students[msg.sender];
        require(s.has_borrowed == true, "Only students with borrowed books can return books.");

        
        if(block.timestamp - s.borrowed_at > BORROW_DURATION ) {
            // if late, adds hold order and fine to student
            s.has_hold_order = true;
            s.balance += DEFAULT_FINE;
        } else {
            // no fines, the student returns it before the deadline
        }

        // clears the variables set by the borrow function
        s.has_borrowed = false;
        s.borrowed_at = 0;
        s.current_book = "";
    }

    function payBalance() public payable onlyEnrolled hasHoldOrder {
        // allows student to pay the balance
        // setting limitation that the payment must be equal to the balance
        // a one-time big payment that clears the hold order
        // simplifies the system, and why would you have partial payments? just make the payment when
        // you have enough wei because partial payments wont lift your hold order
        Student storage s = students[msg.sender];
        require(msg.value == s.balance, "You need to pay your exact balance in wei.");

        s.has_hold_order = false;
        s.balance = 0;

    }
}
