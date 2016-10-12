---
title: Using Groovy to write Atlassian plugins
date: 2016-09-27
tags:
- atlassian
- jira
- confluence
- plugins
- sdk
- gmavenplus
draft: false
author: Steve Good
aliases:
- /2016/09/27/using-groovy-to-write-atlassian-plugins.html
---

Writing plugins for Atlassian products is pretty straight forward (once you get passed the insanely out-of-date documentation).  But using Java can be overly verbose and less flexible than some other more modern languages.  There are examples of writing plugins using [Scala](https://bitbucket.org/ssaasen/atlassian-scala-example-plugin) and [JRuby](https://bitbucket.org/ssaasen/atlassian-jruby-example-plugin) out there but documentation for using [Groovy](http://groovy-lang.org/) seems to be a bit of a black hole.  Since Groovy is my JVM language of choice, I have decided to document the process and give a simple example.

## Getting started

Before you start you need to make sure that you have [installed the Atlassian SDK](https://developer.atlassian.com/docs/getting-started/set-up-the-atlassian-plugin-sdk-and-build-a-project). Once you have that installed we can create a new JIRA plugin.  These steps should work fine for RefApp plugins as well as Confluence.

### Create a project

- Run ```atlas-create-jira-plugin``` from the command line
    - groupId: _rocks.stevegood.jira_
    - artifactId: _my-groovy-plugin_
    - version: _1.0.0-SNAPSHOT_
    - package: _rocks.stevegood.jira_
    - Y: _y_

### Modify your ```pom.xml```

#### Add the _groovy-all_ dependency to your plugin

```xml
...
<dependency>
    <groupId>org.codehaus.groovy</groupId>
    <artifactId>groovy-all</artifactId>
    <version>${groovy.version}</version>
    <scope>compile</scope>
</dependency>
...
```
#### Add the GMavenPlus plugin to your _plugins_ block

```xml
...
<plugin>
    <groupId>org.codehaus.gmavenplus</groupId>
    <artifactId>gmavenplus-plugin</artifactId>
    <version>1.5</version>
    <executions>
        <execution>
            <goals>
                <goal>execute</goal>
                <goal>compile</goal>
                <goal>testCompile</goal>
            </goals>
        </execution>
    </executions>
    <dependencies>
        <dependency>
            <groupId>org.codehaus.groovy</groupId>
            <artifactId>groovy-all</artifactId>
            <version>${groovy.version}</version>
            <scope>runtime</scope>
        </dependency>
    </dependencies>
</plugin>
...
```

### Update the instructions for the _maven-jira-plugin_ plugin

```xml
...
<instructions>
  ...
  <Import-Package>
    ...
    *;version="0";resolution:="optional",
    ...
  </Import-Package>

  ...

  <DynamicImport-Package>
    *
  </DynamicImport-Package>
  ...
</instructions>
...
```

#### Add the _groovy.version_ property to the _properties_ block

```xml
...
<groovy.version>2.4.7</groovy.version>
...
```

### Update your project structure

1. Rename ```src/main/java``` to ```src/main/groovy```
2. Rename ```src/test/java``` to ```src/test/groovy```
3. Rename **all** ```*.java``` files to ```*.groovy```
4. Fix the _MyPluginComponentImpl.groovy_ file (around line 11) so that it compiles
  - Change ```@ExportAsService({MyPluginComponent.class})``` to ```@ExportAsService([MyPluginComponent])```

### Clean up code and run the plugin

You can now go through your files are remove things like semicolons, parenthesis, and _public_ scope declarations. At this point you should be able to start your plugin with ```atlas-run```.  If it doesn't work, verify that you have made all of the changes listed above and try again.  You might also try cleaning your project first to avoid lingering artifacts with ```atlas-clean```.  You can also checkout the [example source code](https://github.com/stevegood/my-groovy-plugin) if you get stuck.

Once you have JIRA running you should be able to see that your plugin has loaded from the [Manage Addons](http://localhost:2990/jira/plugins/servlet/upm) screen.  You should see something similar to the this:

![manage-addons-my-groovy-plugin](/images/post/manage-addons-my-groovy-plugin.png)
