Instructions for filling out emails.txt configuration file (in public/system):

File should contain the following 8 tab-delimited lines (blank lines ignored, included for readability):

Send_From <Email>               where <Email> is email address to be used for sending emails from the system
Admin_To  <Email>               where <Email> is email address of system admin (debug emails will be sent here)

Samples_Email <Env>             where <Env> is either Production, Test, or NoEmail
Samples_Delivery  <Delivery>    where <Delivery> is Deliver, Debug or None
Samples_To  <Email>             where <Email> is comma-separated list of email addresses to which new samples should be sent

Orders_Email <Env>              where <Env> is either Production, Test, or NoEmail
Orders_Delivery <Delivery>      where <Delivery> is Deliver, Debug or None
Orders_To <Email>               where <Email> is comma-separated list of email addresses to which new orders should be sent

Notes:
<Env> = Production - emails sent to Orders_To email address(es); Test - emails sent to Admin_To address only; NoEmail - no email generated
<Delivery> = Deliver - normal email delivery; Debug - email displayed on screen in debug mode; None - email not sent or displayed

