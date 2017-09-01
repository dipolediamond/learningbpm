---
layout: post
title: How to create tabs in ProcessMaker
tags: processmaker how-to
subclass: 'post tag-content'
categories: 'dipole'
navigation: True
logo: 'assets/images/lbpm_dark_logo.png'
disqus: true
---

While recently working with a client to replicate a process built in another BPM in ProcessMaker, there was a concern that was foremost on his mind.

> I know ProcessMaker does not have tab control. What is your suggestion in designing this form in ProcessMaker?

The assertion that ProcessMaker does not have a tab control is accurate and tabs can be very useful in improving the user experience for forms with a large number of fields.

After a little thought, I proposed two approaches —

1.  We can use collapsible sections of the form and toggle the visibility of each section with buttons placed at the top of the form using javascript.
2.  Alternatively, we can create separate dynaforms and the user can use the **Next step** or **Previous step** links to move between the forms for a task.

![Initial idea for approach 1 — using buttons at the top of the form.](https://cdn-images-1.medium.com/max/1600/1*bbv7pfiP_vfy6a8LhD9cGg.png)
Initial idea for approach 1 — using buttons at the top of the form.