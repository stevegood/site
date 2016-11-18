---
author: Steve Good
date: 2012-08-23
draft: false
tags:
- programming
- groovy
title: Simple URL Monitor Using Groovy and Twilio
---

Recently, the need arose for me to monitor a URL so that notifications could be sent out if the site was suddenly unavailable. Later on down the road this will need to evolve into a more proactive system rather than reactive but for now I am just focusing on site down notifications.

To start, I set some minimal requirements for myself.

- Needs to be easy to write, can't take more than an hour to build
- Needs to be easy to maintain, problems should be easy to find and fix
- Needs to be able to send SMS messages in case of outages
- Needs to be able to run standalone or on a server under cron

When looking at the requirements I had to think about what kind of scripting environment would be best served for the task.  I had several options available to me each with pros and cons.

- bash
    - Pros
        - Runs natively on any \*nix based system
    - Cons
        - Extremely verbose
        - Will not run on non \*nix based systems
- Perl
    - Pros
        - I would be able to drudge up ancient knowledge that I had buried deep in the catacombs of my mind
    - Cons
        - I don't have enough time to drudge up my ancient, and dusty, knowledge of Perl
        - I would spend too much time trying to figure out how to do everything in a single line of code
- Groovy
    - Pros
        - I work with Groovy every day at work
        - I can use Grape to supply dependencies using the ```@Grab``` annotation
        - Code tends to be clean and simple
        - Can be run on any system that has Groovy installed
    - Cons
        - Must have Groovy installed
        - It is a little slow to startup

It should be no surprise that I chose to use Groovy for this project.  For me, Groovy just fits the bill better in terms of code verbosity and features available.

Building the script was a snap.  One of the cool things about shell scripting is that you are able to specify the binary that you want to use to execute your script. So by adding a single line of declaration I was able to create a script that can run as if it was a native executable.

```bash
#!/usr/bin/env groovy
```

After that it's just a matter of writing the code that does the work!  Lets start with the dependent libraries.

First I needed to make sure I had the HTTP-Builder library.  Grape makes this a snap to get by letting me take advantage of the ```@Grab``` annotation. I just place the following towards the top of my script and like magic everything I need is available.

```groovy
@Grab(group='org.codehaus.groovy.modules.http-builder', module='http-builder', version='0.5.2')
```

I also need to make sure I have the Apache commons httpclient libraries.  I use another ```@Grab``` to do this.

```groovy
@Grab(group='commons-httpclient',module='commons-httpclient',version='3.1')
```

Grape is actually going out to the maven repositories and downloading the jars I requested and adding them to my classpath.  Pretty slick eh?

I'll skip the imports (but you can check out the full source if those kinds of things excite you) and just straight to the guts of the script.

Next, among other things, I wanted to make sure that the script was configurable enough that I could add a list of phone numbers and be able to easily specify the url to monitor. To do that I created a nice little HashMap of key value pairs.

```groovy
def now = new Date()
def options = [
  server: "https://google.com/",
  intervalSeconds: 600,
  sid: "",
  authToken: "",
  fromPhone: "",
  toPhone: "",
  smsOnStart: false,
  smsOnStartMessage: "Site monitoring script started at ${now.format('H:mm:ss')} on ${now.format('yyyy-MM-dd')}"
]
```

Ok, so options are great, but without some functionality they really mean nothing. Next I define two functions.

Here's the method that sends the SMS.

```groovy
def sendSMS(def message, def opts){
  if (opts.sid != "" && opts.authToken != "" && message != ""){
    String twilioHost = "api.twilio.com"
    String sid = opts.sid
    String authToken = opts.authToken

    def hc = new HostConfiguration()
    hc.setHost(twilioHost, 443, "https")
    def url = "/2010-04-01/Accounts/$sid/SMS/Messages"

    def client = new HttpClient()
    Credentials defaultcreds = new UsernamePasswordCredentials(sid, authToken)
    client.getState().setCredentials(null, null, defaultcreds)

    opts.toPhone.split(',')?.each { toPhn ->
      PostMethod postMethod = new PostMethod(url)
      postMethod.addParameter("IfMachine","Continue")
      postMethod.addParameter("Method","POST")
      postMethod.addParameter("From",opts.fromPhone)
      postMethod.addParameter("To",toPhn)
      postMethod.addParameter("Body",message)

      client.executeMethod(hc, postMethod)

      postMethod.releaseConnection()
    }
  }
}
```

And here's the method that checks the status of the url.

```groovy
def doPing(def opts) {
  if (opts.server != ""){
    try {
      new HTTPBuilder( opts.server ).get( path:'' ) { response ->
        def msg = ""
        if (response.statusLine.statusCode == 200){
          msg = "${new Date()} :: UP!"
          println msg
        } else {
          msg = "${new Date()} :: There might be a production problem! -> ${response.statusLine.statusCode}"
          println msg
          sendSMS(msg,opts)
        }
      }
    } catch( e ){
      println "${new Date()}"
      e.printStackTrace()
      sendSMS("There was an error when connecting to the production server, it might be down.",opts)
    }

    if (opts.intervalSeconds > 0){
      def then = new Date()
      then.seconds += opts.intervalSeconds
      println "Checking again at ${then}"
      while (new Date() <= then){
        // do nothing
      }

      doPing( opts )
    }
  }
}
```

Since these are both method declarations and they won't just call themselves we need to do one last thing, call the doPing method.

```groovy
if (options.smsOnStart){
  sendSMS(options.smsOnStartMessage,options)
}

doPing( options )
```

That's the whole script! If you are interested in looking at or using the script [Github's](https://github.com/stevegood/groovy-url-monitor) going to be the best place to do that. With comments and code the whole thing come to a mere 106 lines of code! Not bad for something that monitors a URL and then sends an SMS when there is a problem.

I know I glossed over how the methods actually work but I felt they were pretty self explanatory. Feel free to ask questions in the comments if you would like further explanation.

Thanks for reading!
