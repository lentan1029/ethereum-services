pragma solidity ^0.4.2;

contract Event {  // can be killed, so the owner gets sent the money in the end

  address public organizer;
  string public eventName;
  mapping (address => string) public attendeesPaid;
  uint public numAttendees;
  uint public quota;
  uint public price;
  uint public eventCreateDateTime;
  uint public eventStartDateTime;
  uint public eventEndDateTime;

  event PurchaseTicket(address _from, uint _amount, uint _numAttendees); // so you can log the event
  event RefundTicket(address _to, uint _amount); // so you can log the event
  event InsufficientEther(uint _amountSent, uint _price);
  event CreateEvent(address _organizer, uint _numAttendees, uint _quota, uint _price, string _eventName, uint _eventCreateDateTime, uint _eventStartDateTime, uint _eventEndDateTime);
  event ExceedQuota(uint _numAttendees, uint _quota);

  function Event(string _eventName, uint _price, uint _quota, uint _eventCreateDateTime, uint _eventStartDateTime, uint _eventEndDateTime) { //TODO: add params to customize the event
    organizer = msg.sender;
    eventName = _eventName;
    price = _price;
    quota = _quota;
    numAttendees = 0;
    eventCreateDateTime = _eventCreateDateTime;
    eventStartDateTime = _eventStartDateTime;
    eventEndDateTime = _eventEndDateTime;
    CreateEvent(organizer, numAttendees, quota, price, eventName, eventCreateDateTime, eventStartDateTime, eventEndDateTime);
  }

  // payable keyword is necessary to allow for transfer of ether.
  function buyTicket(string _name) payable {
    if (numAttendees > quota) {
      ExceedQuota(numAttendees, quota);
      throw; // throw ensures funds will be returned
    }

    if (msg.value < price) { //
      InsufficientEther(msg.value, price);
      throw;
    }

    attendeesPaid[msg.sender] = _name;
    if (!organizer.send(msg.value)) throw; //send ether but catch error
    numAttendees++;
    PurchaseTicket(msg.sender, msg.value, numAttendees);
  }

  function getNumAttendees() constant returns (uint){
    return numAttendees;
  }

  function verifyAttendee(address _attendee) constant returns (string) {
    if (bytes(attendeesPaid[_attendee]).length > 0) {
      return attendeesPaid[_attendee];
    } else {
      return "";
    }
  }

  // function refundTicket(address recipient, uint amount) public {
  //   if (msg.sender != organizer) { return; }
  //   if (attendeesPaid[recipient] == amount) {
  //     address myAddress = this;
  //     if (myAddress.balance >= amount) {
  //       if (!recipient.send(amount)) throw;
  //       RefundTicket(recipient, amount);
  //       attendeesPaid[recipient] = 0;
  //       numAttendees--;
  //     }
  //   }
  //   return;
  // }

  function destroy() {
    if (msg.sender == organizer) { // without this funds could be locked in the contract forever!
      suicide(organizer);
    }
  }
}
