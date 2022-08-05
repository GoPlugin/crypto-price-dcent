const { Requester, Validator } = require('@goplugin/external-adapter')
const { ethers } = require('ethers');

require("dotenv").config();

const customError = (data) => {
  if (data.Response === 'Error') return true
  return false
}

const createRequest = (input, callback) => {
  const url = `https://min-api.cryptocompare.com/data/price?fsym=${input.data.fsymbol}&tsyms=${input.data.tsymbol}`;
  console.log("input data, ", input.data);
  const config = {
    url
  }

  Requester.request(config, customError)
    .then(response => {

      console.log("response value is ", response);

      // var totalTokenToSend = response.data[input.data.tsymbol];
      // console.log("totalTokenToSend  ,", totalTokenToSend);
      const res = {
        data: {
          "result": response.data[input.data.tsymbol].toString()
        }
      }
      callback(response.status, Requester.success(input.id, res));
    })
    .catch(error => {
      callback(500, Requester.errored(input.id, error))
    })
}

module.exports.createRequest = createRequest
