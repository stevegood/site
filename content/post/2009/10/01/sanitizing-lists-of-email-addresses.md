---
date: 2009-10-01
title: Sanitizing Lists of Email Addresses
draft: false
slug: sanitizing-lists-of-email-addresses
author: Steve Good
tags:
- coldfusion
- regex
---

I ran across an exception today where an email address was not being validated on submit or server side.  Obviously this is something that needs to be done, but what about when you have a list of email addresses?  The app I'm working on is old and lacks validation in most of the key areas.  To combat this I created a method in a util object that will loop over a list of email addresses and validate each one by removing anything that does not match an email address structure.

The method is pretty simple.  It loops over the supplied list, applies some regex to locate the first email address within the string, appends it to a new list that is returned.  See below.

```xml
<cffunction name="sanitizeEmailList" access="public" returnType="String" output="false">
  <cfargument name="emailList" type="String" required="true" />

	<cfset var local = {} />
  <cfset local.email = '' />
  <cfset local.RegEx = "[a-z0-9!##$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!##$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"/>

  <cfloop list="#arguments.emailList#" index="local.i">
    <cfset local.address = ReMatch(local.RegEx,local.i)/>
    <cfif ArrayLen(local.address)>
      <cfset local.email = ListAppend(local.email,local.address[1]) />
    </cfif>
  </cfloop>

  <cfreturn local.email />
</cffunction>
```
This is by no means an excuse to not validate form input, but it does help me get through some pretty ugly legacy code.

*Update: I swapped out the regex used for one that was shared with me by [James](http://twitter.com/Clarkee21) via Twitter.  My regex would have failed on any addresses that were formatted as my.address+filter@gmail.com.  My regex would have dropped anything from the + back.  Using his this no longer becomes an issue.*
