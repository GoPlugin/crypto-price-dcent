/* eslint-disable */
const Xdc3 = require("xdc3");
require("dotenv").config();
const h = require("chainlink-test-helpers");
const express = require('express')
const bodyParser = require('body-parser');
const app = express()
const port = process.env.EA_PORT || 5001

app.use(bodyParser.json())

app.post('/api/pullPrice', async (req, res) => {

  console.log("request value is", req.body.fsystm, req.body.tsystm);

  const xdc3 = new Xdc3(
    new Xdc3.providers.HttpProvider(process.env.CONNECTION_URL)
  );

  const buyer = req.body.payer;
  const deployed_private_key = process.env.PRIVATE_KEY;
  const jobId = process.env.JOB_ID;
  const oracle = process.env.ORACLE_ADDRESS;
  const fsystm = req.body.fsystm;
  const tsystm = req.body.tsystm;

  console.log("Buyer Address is, ", buyer);

  const requestorABI = require("./ABI/requestAbi.json");
  const requestorcontractAddr = process.env.REQUESTOR_CONTRACT;

  // // //Defining requestContract
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();

  const tx = {
    nonce: nonce,
    data: requestContract.methods.requestPrice(oracle, jobId, fsystm, tsystm, buyer).encodeABI(),
    gasPrice: gasPrice,
    to: process.env.REQUESTOR_CONTRACT,
    from: account.address,
  };

  const gasLimit = await xdc3.eth.estimateGas(tx);
  tx["gasLimit"] = gasLimit;

  const signed = await xdc3.eth.accounts.signTransaction(
    tx,
    deployed_private_key
  );

  const txt = await xdc3.eth
    .sendSignedTransaction(signed.rawTransaction)
    .once("receipt", console.log);
  var request = h.decodeRunRequest(txt.logs[3]);
  const resultset = { requestId: request.id, requestData: request.data.toString("utf-8") };
  console.log("resultSet  ,", resultset)
  res.send(resultset)
})

app.listen(port, () => console.log(`Listening on port ${port}!`))
