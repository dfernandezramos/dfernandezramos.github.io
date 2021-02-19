---
title: "Developing user stories"
date: 2020-02-19
hero: /images/posts/miscommunication.png
# categories:
# - writing-posts
# - writing-posts-category
---

Last week, in a little meeting we usually do to close our SCRUM Sprint period of two weeks, I was showing all the new features I had developed for our product. One of the features was not accepted and therefore its related user story was moved back from "QA Review" to "On development" again. I misunderstood my task.

What can we do here? Should we just tell the developer what was wrong and wait for him to change it ASAP or maybe should we try to guess what led him to do it that way the first time to see if we have a problem in our product development workflow? We think that the only way to improve is by learning from our own mistakes and we checked what was wrong: the user story was not well defined and I decided to do a freestyle with my imagination for the definition of done.

Generally an Agile user story is written by the product owner or product manager and submitted for review. It is very important to polish the way we define them since it is the main reference point between the developers and the rest of the people involved in the product definition, therefore the main focus of miscommunications.

---
##### How was the user story defined in first place?

Here you can see how the user story was defined. The main concept is pretty clear. Our software works with a previous login and we want a place where the user can see which user is logged in and offer him the possibility to log out.

{{< img src="/images/posts/userstory_bad.png">}}

You maybe already noticed that this is not a proper user story and it definitely needs more information but trust me, as a developer when you are on a hurry most of the times your head does not stop to think correctly and say: hey, you can do it because you already (barely) remember that talk you had with the project manager and you have this new feature perfectly pictured in your head. WRONG!

Where is the place you have to put that information? Is the user email the only information we have? Should the log out option do anything different than what it does now? Etc.

##### What was the first error?

Was it defining this way that user story? Most of the time product managers create their main ideas of a user story or task and let them in the backlog for future refinement and definition.

Was it starting to develop that story without asking for more definition? As I said, developers can think they have  most of the information because of internal talks or chat conversations and most of the time they are running in a hurry because of deadlines (and this happen so often in small teams where one person does more than one job and has a better vision of the product, or at least thinks he/she has).

So what? Where was the first error? Well, we are a team and as a team we all have to take part in that kind of errors. In the first place, the project manager could have been aware to not put that user story to be evaluated by the technical team in the Sprint planning, but then the technical team could have been aware of that and rejected to evaluate the story points needed to finish that story without a definition. They all discussed that story and then voted for it.

If a story ends up on a sprint board, it means that all of the team agreed on that and therefore has been involved in it.

##### Hands on a properly defined story:

Keep in mind that each company or team is a world and I'm going to define how a proper user story or task should be defined for me as a developer.

> What information do we need on a user story or task?
>> * `Rationale` ->> The short way to explain the reason for the story. We use the next format: `As a *** I want to *** so that ***`
>> * `Description (optional)` ->> A detailed description of what we want and explain the behavior of the feature (add design images if needed). It is optional because sometimes the rationale can already describe pretty well what we need.
>> * `Acceptance criteria` ->> Series of what we call "story test" to clarify the desired behavior. These tests are used by the development team for a better understanding on what to build and test and by the product owner to confirm that the user story has been implemented to his satisfaction. Every User Story must have defined the acceptance criteria. It can also help the QA team to understand the feature and define their first basic tests.

> What information do we need on a bug?
>> * `Description` ->> A detailed description of what happens.
>> * `Steps to reproduce` ->> Detailed step by step guide to reproduce the issue with the current result and the expected result.
>> * `Resources (optional)` ->> Log files the user has sent, images, videos, etc. 

##### Result and conclusions:

After following the proposed guidelines we can obtain a very different user story from the first one I have posted at the beginning of this post:

{{< img src="/images/posts/userstory_comparison.png">}}

Now we don't only have a user story that barely tells what we want but it also tells you why. In addition, the developer has a context and definition with images whe the design in case it is needed and also has a very important section for the definition of done with some scenarios that can help not only the developer but also the project manager and the QA team to do their respective work.

This week I have read a LinkedIn post from a good ex-teammate [Jorge Luna](https://es.linkedin.com/in/jorgelunakuhn), who is the CPO in its company now, saying that he has created some tags on Jira for all the stories like "Needs definition", "Needs design", "Needs whatever" in order to filter them and avoid forgetting something and start a sprint planning with undefined stories. It's so tedious when all the team has to stop the sprint planification waiting for the project manager to define it "in a minute" because it is very important and it needs to be evaluated for this sprint.

##### Sources:

* https://www.atlassian.com/agile/project-management/user-stories
* https://www.workfront.com/project-management/methodologies/scrum/sprints

---
<br />

As developers, we should learn to say a big NO to not defined tasks or stories because if something goes wrong then you will be the one who has done it wrong because... Why did you start working on something you needed more information about without asking for it?

If you would like to know something else about our Agile process don't hesitate to comment if below. See you all in the next post!