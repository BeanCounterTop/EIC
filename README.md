# EIC
Environment-In-a-Can 

I created this project in 2015 to support the Jive DevOps efforts.  It automates the creation and configuration of a full Microsoft environment (including clients) for use in testing and developing Jive's Sharepoint integration, incorporating and extending the AutoSPInstaller project.  It represents a fairly early stage of my Powershell automation journey.

The configuration is contained within a single XML file and is meant to be managed with a tool like XMLNotepad.

This project implements:
* Active Directory
* Microsoft PKI
* ADFS
* Sharepoint 2010 and 2013
* Lync 2013
* Pidgin
* Polipo web-caching proxy
