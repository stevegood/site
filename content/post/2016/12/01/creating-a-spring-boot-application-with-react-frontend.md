---
author: Steve Good
date: 2016-12-01T09:13:53-08:00
draft: true
image: images/post/spring-boot-loves-react.png
tags:
- Spring Boot
- React
- JavaScript
- Groovy
- Gradle
type: post
title: Lets build a Spring Boot app with a React UI!
description: Or, "OMG why was this so difficult to figure out the first time?"
---

It is no secret that I prefer Spring Boot as my current application framework of choice. I use it for both personal and professional projects. For simple webapps as well as large, distributed systems (microservices). Spring Boot is a great framework for this kind of work but what about for powering single page applications? While there are a number of JavaScript frameworks available for this kind of thing, my current favorite is React. While not strictly a framework, React fits nicely into my thought process of bringing only the libraries I need into my applications. Bringing these two technologies together has been an interesting, and sometimes frustrating, process. In this post I'll cover one of the methods I use for simple single interface apps.

## Create the root Gradle project

Before we dive into creating the Spring Boot and React apps we need to create a root Gradle project. Using Gradle, and sub-projects, will allow us to keep the two portions of the application separate while still allowing the build process to stay unified.

_**Prerequisite**: You will need to have Gradle installed before moving forward, I suggest using SDKMan for this._

1. Initialize a new project

    ```bash
    mkdir -p ~/Projects/spring-boot-loves-react
    cd ~/Projects/spring-boot-loves-react
    gradle init wrapper
    rm build.gradle
    ```

2. Setup the folder structure

    ```bash
    mkdir backend
    mkdir frontend
    ```

## Create the Spring Boot application

### Create a new application

### Gather dependencies


## Create the React application

### Create a new application

### Gather dependencies

## _Optional:_ Set up an IntelliJ IDEA project

## Conclusion
