
# Swift implementation of the project Yuga

This is the Swift implementation of the Yuga project which identifies and tokenises a lot of important information. This implementation is needed for the tokenisation of the messages which in turn is required by the iOS categoriser

# How it works ?

Messages need to be passed to the API and the method getYugaTokens() returns the tokenised form of the message with the starting indices of all the tokens in a dictionary.
The message is traversed character by character until the next delimiter is found and we go word by word in a message to extract relevant tokens.

## Demo

message : "Your A/c no xx1234 is credited with Rs 3000 on 11/11/20 Ref no 8379294 Current A/c Bal Rs 12000"

We can call the method getYugaTokens() as getYugaTokens(message) and the output is the tokenised message with the metadata.

Output : Your A/c no INSTRNO is credited with AMT on DATE Ref no NUM Current A/c Bal AMT METADATA : ["AMT": { INDEX = 36; }, "AMT_1": { INDEX = 87; }, "NUM": { INDEX = 63; }, "INSTRNO": { INDEX = 12; }]


