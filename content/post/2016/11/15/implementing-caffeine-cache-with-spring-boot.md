---
author: Steve Good
date: 2016-11-15T14:55:39-08:00
draft: false
image: images/post/spring-boot-hearts-caffeine.gif
tags:
- post
- spring boot
- caffeine
- cache
- java
- groovy
title: Implementing Caffeine Cache with Spring Boot
---

Implementing a cache, even a basic one, used to require lots of architectural discussion, meetings, evaluations, and a significant amount of development time. With [Spring Boot](http://projects.spring.io/spring-boot/), those days are far behind us! With a small amount of configuration, dependency management, and a few annotations any developer can have caching set up in their application in a few minutes.

## Generating a new application

Using either the [Spring Boot CLI](http://docs.spring.io/spring-boot/docs/current/reference/html/getting-started-installing-spring-boot.html#getting-started-sdkman-cli-installation) or the [Spring Initializr](https://start.spring.io), create a new application using the following (unless specified, use the defaults):

- Gradle Project
    - You could use Maven also, just replace the ```./gradlew``` commands with ```mvn```
- Version: _1.4.2_
    - Higher versions should also work, this was just the most current version as of this writing
- Language: _Groovy_
    - Not required but I prefer writing less verbose code
- Packages
    - Cache _(Core)_
    - Web _(Web)_
    - Thymeleaf _(Template Engines)_

## Write a simple web app

For this demo we are going to build a simple HTML page that displays the current time. Exciting right?! For this, we will need a build a controller and a view.

### The controller and the view

Create a new Groovy class in the ```com.example``` package named **TimeController** with the following content.

```groovy
package com.example

import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.RequestMapping

@Controller
class TimeController {
    
    @RequestMapping
    def index(Model model) {
        model.addAllAttributes now: (new Date().time)
        'index'
    }
    
}
```

Next, create the view in ```src/main/resources/templates``` directory and named **index.html** with the following content.

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Caffeine Cache Demo</title>
</head>
<body>
    <p th:text="'Now: ' + ${now}"/>
</body>
</html>
```

### Run the application

From a terminal, use the Gradle wrapper to start the application.

```./gradlew bootRun```

Once the application has started up, you should be able to view it running at [localhost:8080](http://localhost:8080/). The page should show the current time in milliseconds.  Each time you refresh the page the time should be updated.

## Add basic cache functionality

We already added the dependency for Spring Cache all we need to do now is enable the cache and cache something. This is the easy part. Well, all of it is the easy part.

### Enable caching

Modify ```com.example.DemoApplication``` so that it matches the following (note the ```@EnableCaching```)

```groovy
package com.example

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.cache.annotation.EnableCaching

@SpringBootApplication
@EnableCaching
class DemoApplication {

	static void main(String[] args) {
		SpringApplication.run DemoApplication, args
	}
}
```

### Create a service for getting time

We want to better encapsulate how our application gets time. This will help us apply caching in a more organized way.

Create a Groovy class in the ```com.example``` package named **TimeService** with the following content.

```groovy
package com.example

import org.springframework.stereotype.Service

@Service
class TimeService {

    long getTimeNow() {
        new Date().time
    }

}
```

Modify the ```com.example.TimeController``` class to get the current time from the TimeService. Note the addition of ```TimeService``` being autowired as well as the call to ```timeService.timeNow``` in the map of attributes being added to the model.

```groovy
package com.example

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.RequestMapping

@Controller
class TimeController {

    @Autowired
    TimeService timeService

    @RequestMapping
    def index(Model model) {
        model.addAllAttributes now: timeService.timeNow
        'index'
    }

}
```

### Add a cached method

Running the application at this point will yield the same behavior we had previously. We have not added anything to that needs to be cached. Lets do that now. In the ```com.example.TimeService``` class add a new method named _getTimeCached_ and have it return a call to _getTimeNow_. Lets also add a new annotation, ```@Cacheable``` to the method that tells Spring Boot to cache the results of the method. It should now look like the following.

```groovy
package com.example

import org.springframework.cache.annotation.Cacheable
import org.springframework.stereotype.Service

@Service
class TimeService {

    long getTimeNow() {
        new Date().time
    }
    
    @Cacheable('timeCached')
    long getTimeCached() {
        timeNow
    }

}
```

By adding the ```@Cacheable``` annotation to the method, we are instructing Spring Boot to manage a HashMap cache with the method's result. The name _timeCached_ in the annotation is the name of the cache key we want to use. This makes things easier when you want to manipulate specific cached data.

### Use the cached method and render the result in the view

The last step is to start using the new method and render its result in the view. Back in the ```com.example.TimeController``` class, add a new key to the attributes map.  It should now look like this:

```groovy
model.addAllAttributes now: timeService.timeNow, cached: timeService.timeCached
```

And in ```src/resources/templates/index.html``` add the following line above the closing ```</body>``` tag.

```html
<p th:text="'Cached: ' + ${cached}"/>
```

### Test it out

Restart the application and refresh the page in your browser.  You'll notice that in addition to the time now we are also showing the cached time. If you refresh the page only the time now will change and the cached time will stay the same indefinitely. Congratulations, now you're caching with ease!

## Improve caching with Caffeine

Having a cache that lives for the life of the application might fit your use case but it also comes with some issues. What if the data you are caching changes over time? What if you want to control the size of the cache? In this section, we are going to implement a cache library called [Caffeine](https://github.com/ben-manes/caffeine). Caffeine is an in-memory cache aimed at replacing Google's Guava. It is high performance and light weight, perfect for our simple application.

### Add the Caffeine library to the application

In your ```build.gradle``` file, add the following line to the _dependencies_ block.

```groovy
compile 'com.github.ben-manes.caffeine:caffeine:2.3.5'
```

Maven users can add the following to their ```pom.xml```.

```xml
<dependency>
    <groupId>com.github.ben-manes.caffeine</groupId>
    <artifactId>caffeine</artifactId>
    <version>2.3.5</version>
</dependency>
```

Technically that is all you need to do for Spring Boot to start using Caffeine as the cache provider. However, it will operate exactly the same as before. Lets add some configuration to override the default behavior.

### Configure Caffeine

By default Spring Boot comes with a configuration file named _application.properties_ in the ```src/resources``` directory. I am not a fan of typing the same words over and over again so I prefer to use YAML (you can read more about Spring Boot's configuration files on its project page). Start by renaming _application.properties_ to _application.yml_. Spring Boot will automatically recognize this as a valid configuration file. Open the file and add the following content.

```yaml
spring:
  cache:
    cache-names: timeCached
    caffeine:
      spec: expireAfterAccess=30s
```

This bit of configuration instructs Spring Boot to configure Caffeine with a cache named _timeCached_ that expires after 30 seconds of inactivity.

### Run it

Restart the application (if it is still running) and navigate to [localhost:8080](http://localhost:8080/).  You'll see the same output as the last time we checked in on our application. Refresh the page a few times to verify that we are still caching the time. Now, wait 30 or more seconds and try refreshing the page. You should see that the cached time has been updated. Refresh a few more times to verify that the new time has been cached.

### Use a better eviction policy

Great, we have a cache that expires after 30 seconds. Or does it? Re-read that last paragraph. You will note that I mentioned the cache will expire after 30 seconds of inactivity. This means that if the cache is written to or read from at any point during those 30 seconds the eviction timer will reset. This will quickly turn into a cache that appears to never expire in applications that access the cache more frequently that the eviction policy dictates. This could be bad. What we really want, is a cache that expires 30 seconds after it has been written. Lets make a small tweak to the _application.yml_ file.

```yaml
spring:
  cache:
    cache-names: timeCached
    caffeine:
      spec: expireAfterWrite=30s
```

With this change the cache data will be evicted 30 seconds after it has been written. You can read more about [eviction policies](https://github.com/ben-manes/caffeine/wiki/Eviction) on the Caffeine wiki.

## Conclusion

Congratulations, you made it! You have a simple application that caches some data with a time based eviction policy. Spring Boot supports a number of different caching providers including, EHCache, Redis, and Hazlecast. Most of these can be configured in a similar way but all of them will leverage the same implementation in your code. The ```@Cacheable``` and ```@EnableCaching``` annotations abstract away the implementation details so that you can focus on your application and the minimal configuration. Also, if you got stuck anywhere, feel free to refer back to the [finished sample application on GitHub](https://github.com/stevegood/caffeine-cache-spring-boot-demo).

Good luck and happy caching!
