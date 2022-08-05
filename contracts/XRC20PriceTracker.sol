// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@goplugin/contracts/src/v0.8/PluginClient.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DecentralizedPrice is PluginClient {
    using Plugin for Plugin.Request;
    using Counters for Counters.Counter;
    Counters.Counter private _settlementIds;

    //Initialize Oracle Payment
    uint256 private constant ORACLE_PAYMENT = 0.1 * 10**18;

    address public contractowner;

    struct PriceSettlement {
        uint256 id;
        address buyer;
        string fsystem;
        string tsystem;
        uint256 currencyValue;
        uint256 settledOn;
        bool settled;
    }
    mapping(uint256 => PriceSettlement) settlementId;

    mapping(bytes32 => PriceSettlement) settlementRequestIds;

    //Initialize event RequestPriceFulfilled
    event RequestPriceFulfilled(
        bytes32 indexed requestId,
        uint256 indexed price
    );

    //Initialize event requestCreated
    event requestCreated(
        address indexed requester,
        bytes32 indexed jobId,
        bytes32 indexed requestId
    );

    //Constructor to pass Pli Token Address during deployment
    constructor(address _pli) {
        setPluginToken(_pli);
        contractowner = msg.sender;
        _settlementIds.increment();
    }

    //requestPrice function will initate the request to Oracle to get the price from Vinter API
    function requestPrice(
        address _oracle,
        string memory _jobId,
        string memory _fsymbol,
        string memory _tsymbol,
        address _requestor
    ) public returns (bytes32 requestId) {
        uint256 _settleId = _settlementIds.current();

        settlementId[_settleId] = PriceSettlement(
            _settleId,
            _requestor,
            _fsymbol,
            _tsymbol,
            0,
            0,
            false
        );
        Plugin.Request memory request = buildPluginRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillPrice.selector
        );
        request.add("fsymbol", _fsymbol);
        request.add("tsymbol", _tsymbol);
        request.addInt("times", 1000000000000000000);
        requestId = sendPluginRequestTo(_oracle, request, ORACLE_PAYMENT);
        settlementRequestIds[requestId] = settlementId[_settleId];
        emit requestCreated(msg.sender, stringToBytes32(_jobId), requestId);
    }

    //callBack function
    function fulfillPrice(bytes32 _requestId, uint256 _price)
        public
        recordPluginFulfillment(_requestId)
    {
        PriceSettlement memory settle = settlementRequestIds[_requestId];
        settle.currencyValue = _price;
        settle.settledOn = block.timestamp;
        emit RequestPriceFulfilled(_requestId, _price);
    }

    function getPluginToken() public view returns (address) {
        return pluginTokenAddress();
    }

    //With draw pli can be invoked only by owner
    function withdrawPli() public {
        PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
        require(
            pli.transfer(msg.sender, pli.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    //Cancel the existing request
    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public {
        cancelPluginRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
    }

    //String to bytes to convert jobid to bytest32
    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
}
