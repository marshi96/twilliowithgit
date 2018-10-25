// A system package containing protocol access constructs
// Package objects referenced with 'http:' in code
import ballerina/http;
import ballerina/io;
import wso2/twilio;

documentation {
   A service endpoint represents a listener.
}
endpoint http:Listener listener {
    port:8080
};

documentation {
   A service is a network-accessible API
   Advertised on '/hello', port comes from listener endpoint
}

endpoint twilio:Client twilioClient {
        accountSId:"ACf331ae041a8c2e322afe45a17375e86e",
        authToken:"c2b0d7681841ca2fbb3a57951721aa3f",
            xAuthyKey:"c2c85b2178e4c444fbb975ba55b4994b"

    };
service<http:Service> jsons bind listener {

    documentation {
       A resource is an invokable API method
       Accessible at '/hello/sayHello
       'caller' is the client invoking this resource 

       P{{caller}} Server Connector
       P{{request}} Request
    }
    payload (endpoint caller, http:Request request) {
       http:Response response = new;
       var payload =  request.getJsonPayload();
       match payload {
           json myJsonPayload=>
            {
              //  io:println(myJsonPayload["commits"])
                foreach (commit in myJsonPayload["commits"])
                {
                    io:println(commit["author"]["name"]);
                    io:println(commit["message"]);
                    io:println(commit["timestamp"]);
                    string sms = commit["author"]["name"].toString()+" ......FML..haha made a new change ("+commit["message"].toString()+")("+commit["timestamp"].toString()+")";
                    var details = twilioClient->sendSms("+19163451923", "+94716826014", untaint sms);
                       io:println(commit["timestamp"]);

                    match details {
                        twilio:SmsResponse smsResponse => io:println(smsResponse);
                        twilio:TwilioError twilioError => io:println(twilioError);
                    }
                }
                response.setJsonPayload({"status":"ok"});
            }
            any =>
                {
                     io:println("invalid response");
                     response.setJsonPayload({"status":"error"});
                }
       }
   // io:println(payload);
      //  io:println(request);

        // Send a response back to caller
        // Errors are ignored with '_'
        // -> indicates a synchronous network-bound call
        _ = caller -> respond(response);
    }
}