---
title: "Broken things I found while using Fedora"
description: "List of broken things I encountered running Fedora as my primary OS for a few weeks"
date: 2022-11-05T12:26:05+01:00
draft: false
---

{{< lead >}}
List of broken things I encountered running Fedora as my primary OS for a few weeks
{{< /lead >}}

---

## Background
I've been a macOS user for a while, but while my laptop was being repaired I started using an HP laptop my company gave me and installed Linux on it.

I decided on Fedora as I tried a few distros in the past and Fedora was the only one that didn't break in any way on my old 2010 Macbook Pro.

## The Setup

Hardware:
- HP ProBook 440 G7

Software:
- Fedora Linux 36 (Workstation Edition)
- Gnome 42 + Wayland

## The Issues

## Can't share the whole screen on Discord app, Chrome web apps

This seems to be a common issue with Wayland.

Some windows can be shared, but when trying to share the whole screen, all it shows is the cursor and a black background.

**Fixable?** Yes, but only on Chrome web apps.

### Solution

Within Chrome, enable the `chrome://flags/#enable-webrtc-pipewire-capturer` flag. I could not figure out how to fix standalone apps.

## Can't connect my Airpods Pro

My first gen Airpods Pro won't pair.

I'm not sure on what the cause is. Any other Bluetooth device works fine with the laptop and the Airpods do work with any other device I tried.

**Fixable?** No idea.

### Solution

`null`

## Spotify app settings dropdowns don't work

Clicking on them won't do anything. I tried both the official installer and the Flatpak version.

**Fixable?** Kinda.

### Solution

Click on the dropdown and press space to make it expand.
