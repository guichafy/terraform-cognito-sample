'use strict'

var AWS = require("aws-sdk");
var ssm = new AWS.SSM({ region: 'sa-east-1' });

const getParameters = async () => {
  return await ssm.getParametersByPath({
    Path: '/app/config', /* required */
    Recursive: true
  }).promise();
}



const handler = async (event, context, callback) => {
  var response = {
    statusCode: 200
  }
  try {
    const { Parameters } = await getParameters();
    response.body = JSON.stringify(Parameters);
    response.headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*' // replace with hostname of frontend (CloudFront)
    },
    callback(null, response)
  } catch (err) {
    console.log(err);
    response.statusCode = 500;
    response.body = JSON.stringify(err);
    callback(null, response)
  }

}

exports.handler = handler




// async function teste() {
//   try {
//     await getParameters();
//   } catch (err) {
//     console.error(err);
//   }
// }

// teste();
