---
layout: page
title: about
permalink: /about/
---

{% avatar tlnagy size=200 %}

Hi, I'm Tamas. I'm a graduate student in the
[Biomedial Informatics](http://bmi.ucsf.edu) Program at UCSF working in
[Orion Weiner](http://cvri.ucsf.edu/~weiner/)'s lab on the role
of volume regulation in neutrophil polarization and migration.

I graduated with B.S. degrees in Math and Chemistry from the University of
Kentucky in May 2015. In my time there I worked in the
[Dutch](http://biochemistry.med.uky.edu/users/rdutc2) and
[Moseley](http://bioinformatics.cesb.uky.edu/) groups on determining the
structural characteristics of metastable viral fusion proteins. I also worked on
a new method for predicting novel protein-protein interactions *in silico*. I
also had two summer internships: one as an AMGEN scholar in
[Jennifer Doudna's](http://doudna.berkeley.edu/) group at Berkeley and one with
[Lucas Pelkmans](http://pelkmanslab.org/) at the University of Zurich.


#### Contact

<i class="fa fa-envelope fa-fw"></i> <span style="unicode-bidi:bidi-override; direction: rtl;">moc.ygansamat@samat</span><br>
<i class="fa fa-lock fa-fw"></i> <a href="/misc/Tamas_Nagy_604EA988.asc">Tamas_Nagy_604EA988.asc</a><br>
<i class="fa fa-twitter fa-fw"></i> [\@tlngy](https://twitter.com/tlngy)<br>
<i class="fa fa-github fa-fw"></i> [\@tlnagy](https://github.com/tlnagy/)<br>



#### Site details

This website was last built on {{ site.time | date: '%Y-%m-%d %T %Z'}} using
<span class="prog-info">Jekyll {{ site.data.jekyll_ver }} </span>,
<span class="prog-info">Pandoc {{ site.data.pandoc_ver }}</span>, and
<span class="prog-info">Ruby {{ site.data.ruby_ver }}</span> on a
<span class="prog-info">{{ site.data.os_ver }}</span> machine.

Additionally, it uses the following gems:

<ul>
{% for gem in site.plugins %}
<li><a href="https://rubygems.org/gems/{{ gem }}">{{ gem }}</a></li>
{% endfor %}
</ul>
