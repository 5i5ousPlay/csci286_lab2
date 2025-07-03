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
        require(students[msg.sender].has_hold_order == false, "Only students withou hold orders can perform this operation.");
        _;
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
        // Student storage s = students[msg.sender];
        // require(s.has_borrowed==true, "You don't have a book to return.");
        // returns book; add to balance if late return; set hold order to true
    }

    function payBalance() public payable onlyEnrolled {
        // allows student to pay the balance
        // idk if partial payments should be allowed or if this should be a one time full payment
    }
}
