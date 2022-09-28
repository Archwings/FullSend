// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ClimbingFeed {

    uint internal totalClimbs = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    event ReactToClimb(uint, uint);
    event RemoveReactToClimb(uint, uint);
    //uint reactCounts[] = [0, 0, 0];

    struct Climb {
        address payable owner;
        string name;
        string grade;
        string image;
        string comments;
        string location;
        uint[3] reactCounts;
    }


    // mappings
    mapping(uint => Climb) internal climbs;
    mapping(uint => mapping(address => bool)) internal reacts;


    // logs a climb
    function writeClimb(
        string memory _name,
        string memory _grade,
        string memory _image,
        string memory _comments, 
        string memory _location
    ) public {
        uint[3] memory _reactCounts = [uint(0),0,0];
        //uint _reactCounts = 0;
        climbs[totalClimbs] = Climb(
            payable(msg.sender),
            _name,
            _grade,
            _image,
            _comments,
            _location,
            _reactCounts
        );
        totalClimbs++;
    }

    // reads the climb 
    function readClimb(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory,
        string memory, 
        string memory, 
        uint[3] memory
    ) {
        return (
            climbs[_index].owner,
            climbs[_index].name, 
            climbs[_index].grade,
            climbs[_index].image, 
            climbs[_index].comments, 
            climbs[_index].location, 
            climbs[_index].reactCounts
        );
    }

    // tip the climber of a Climb an amount
    function tipClimber(uint _index, uint256 amount) public payable  {
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            climbs[_index].owner,
            amount
          ),
          "Failed to tip"
        );
    }
    
    // get the number of climbs 
    function getClimbsLength() public view returns (uint) {
        return (totalClimbs);
    }

    // post a react to a climb
    function reactToClimb(uint _index, uint selectionIndex) public {
        require(!reacts[_index][msg.sender], "You already liked the climb");
        reacts[_index][msg.sender] = true;
        climbs[_index].reactCounts[selectionIndex] ++;
        emit ReactToClimb(_index, selectionIndex);
    }

    // remove a react to a climb
    function removeReactToClimb(uint _index, uint selectionIndex) public {
        require(reacts[_index][msg.sender], "You haven't liked the climb");
        reacts[_index][msg.sender] = false;
        climbs[_index].reactCounts[selectionIndex] --;
        emit RemoveReactToClimb(_index, selectionIndex);
    }
}