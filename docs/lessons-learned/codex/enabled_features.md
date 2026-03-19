We need to have ansible lint and syntax check on by default. 

I don't how to separate that concern, I imagine in the rules. One thought to keep the separation of concerns is to maybe put in the ansible specific rules tha thave to be enforced but can be disabled by me or you (like if you are debugging and need to run/repeat quickly) but you HAVE TO 100% of the time output 
