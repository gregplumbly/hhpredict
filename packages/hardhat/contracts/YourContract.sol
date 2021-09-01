// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol"; // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
import "hardhat/console.sol";

contract YourContract is Ownable {
    
    event NewFixture(bytes32 fixtureId, string gameId, uint date);
    event WithdrawWinnings(address player);

    address[] public players;
    address[] public winners;
    bytes32[] public fixtureIds;

    enum resultType {win, lose, draw, noResult} // refers to home teams

    struct Fixture {
        string gameId; // e.g MNUCHE or ARSBRE
        uint date;
        uint16 homeScore;
        uint16 awayScore;
        resultType result;
    }

    struct Prediction {
        bytes32 fixtureId;
        uint16 homeScore;
        uint16 awayScore;
        resultType result;
    }

    mapping (bytes32 => Fixture) public fixtures;
    mapping (address => Prediction[]) public playerToPrediction;
    mapping (address => uint) public playerToAmountDue;

    function createFixture(string memory _game, uint _matchDate) public onlyOwner 
        returns (bytes32) {

        bytes32 fixtureId = keccak256(abi.encode(_game,_matchDate));
        fixtures[fixtureId] = Fixture(_game, _matchDate, 0, 0, resultType.noResult);
        fixtureIds.push(fixtureId);
        
        // Emit an event any time new fixture is created. UI code will listen to this and display
        emit NewFixture(fixtureId, _game, _matchDate);
        console.log('this is a console log');
        return fixtureId;
    }

    function balanceOfPot() public view returns (uint) {
        console.log("Contract balance is %s", address(this).balance);
        return address(this).balance;
    }
    
    function makePrediction(bytes32 _fixtureId, uint16 _homeScore, uint16 _awayScore)
        external payable {
        
        // Check _fixtureId is valid
        require(fixtures[_fixtureId].date != 0, "Fixture Id is invalid.");

        // Allow prediction entry only if it's entered before the match start time
        require(block.timestamp < fixtures[_fixtureId].date, "Predictions not allowed after match start.");
        
        // Make sure they paid :) For now amount to bet is fixed to 0.01 ether for simplicity
        require(msg.value > .001 ether, "Oops - please pay to play!");
        
        // Maintain a list of unique players and also a map of their address and prediction
        if (playerToPrediction[msg.sender].length == 0) {
            players.push(msg.sender);
        }

        resultType result;
        if (_homeScore == _awayScore) {
            result = resultType.draw;
        } else if (_homeScore > _awayScore) {
            result = resultType.win;
        } else {
            result = resultType.lose;
        }

        playerToPrediction[msg.sender].push(Prediction(_fixtureId, _homeScore, _awayScore, result));
    }

    function calculateWinners() external onlyOwner {

        Prediction[] storage playerPredictions;

        for (uint i = 0; i < players.length; i++) {
            playerPredictions = playerToPrediction[players[i]];

            for (uint j = 0; j < playerPredictions.length; j++) {
                if (playerPredictions[j].result == fixtures[playerPredictions[j].fixtureId].result) {
                    winners.push(players[i]);
                }
            } //end of inner for loop

        } //end of outer for loop
        // console.log("Winners %s", winners);


        uint perMatchWinnings = balanceOfPot() / winners.length;

        for (uint i = 0; i < winners.length; i++) {
            playerToAmountDue[winners[i]] += perMatchWinnings;
            // console.log("playerToAmountDue %s", winners[i]);
        }

        // Delete fixtures once done to save storage
        for (uint i = 0; i < fixtureIds.length; i++) {
            delete fixtures[fixtureIds[i]];
        }
        delete fixtureIds;
    }

    function updateResultForMatch(bytes32 _fixtureId, uint16 _homeScore, uint16 _awayScore) external onlyOwner {
        Fixture storage matchToUpdate = fixtures[_fixtureId];
        matchToUpdate.homeScore = _homeScore;
        matchToUpdate.awayScore = _awayScore;
        
        if (_homeScore == _awayScore) {
            matchToUpdate.result = resultType.draw;
        } else if (_homeScore > _awayScore) {
            matchToUpdate.result = resultType.win;
        } else {
            matchToUpdate.result = resultType.lose;
        }
    }

    function withdrawWinnings() public { 
        uint amount_due = playerToAmountDue[msg.sender];
        playerToAmountDue[msg.sender] = 0 ether;
        // https://solidity-by-example.org/sending-ether/
        (bool sent, ) = payable(msg.sender).call{value: amount_due}("");
        require(sent, "Failed to send Ether");

        // Emit a withdraw winning event anytime a player withdraws. UI code will listen to this and take any action as needed
        emit WithdrawWinnings(msg.sender);
    }

    function getMatchCount() public view returns(uint count) {
        console.log('counting the fixtures');
        return fixtureIds.length;
    } 
}
