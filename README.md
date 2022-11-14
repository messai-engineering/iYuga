# iYuga

This is the Swift implementation of the Yuga project which identifies and tokenises a lot of important information.
This implementation is needed for the tokenisation of the messages which in turn is required by the iOS categoriser.
The method getYugaTokens() which returns the tokenised form of the message can be called by passing the message which needs to be tokenised as the parameter.
Example :
message : "Your A/c no xx1234 is credited with Rs 3000 on 11/11/20 Ref no 8379294 Current A/c Bal Rs 12000"
We can call the method getYugaTokens() as getYugaTokens(message) and the output is the tokenised message with the metadata.:
Your A/c no INSTRNO is credited with AMT on DATE Ref no NUM Current A\/c Bal AMT
METADATA : 
["AMT": {
    INDEX = 36;
}, "AMT_1": {
    INDEX = 87;
}, "NUM": {
    INDEX = 63;
}, "INSTRNO": {
    INDEX = 12;
}]
