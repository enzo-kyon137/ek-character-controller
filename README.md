# Enzo Kyon's Character Controller



This is my first Roblox character controller (though it felt like solo developing lol) :)



A simple Humanoid-based character controller focused on movement feel, readability, and compatibility.



Instead of replacing Roblox's character system entirely, the controller works alongside Humanoids while handling movement, sprinting, jumping, momentum, and other locomotion features.



The goal is to provide a plug-and-play controller that works across keyboard, mobile, and gamepad while remaining easy to understand and modify.



Development version: v2.2 | Public version: v1.0.1



---



## What It Does



Features include:



* Sprinting

* AutoJump

* Coyote Time

* Momentum

* Braking

* Configurable keybinds

* Sprint FOV feedback

* Shift-lock remapping

* JumpPower support

* JumpHeight support

* Roblox Animate compatibility

* Mobile support

* Gamepad support



The controller is designed to be dropped into a project and work without requiring a lot of complicated setup. (At least this is a good thing for y'all)



---



## Movement Presets



The controller includes three example presets (these are subjective, so if you don't like any of them, feel free to create your own):



### Vanilla



Attempts to feel similar to Roblox's default movement while keeping smooth turning. (kinda)



Good for general Roblox experiences.



### Enhanced



A momentum-focused preset with slower acceleration and smoother transitions.



Good for platformers and adventure-style experiences. (probably)



### Precise



Instant acceleration, instant turning, and no friction.



Good for obbies, competitive movement, and classic-style gameplay. (tbh it's true)



**Precise is currently the most tested and reliable preset. It's better than these two presets in my opinion, but don't judge me for it :P**



The included presets are examples rather than final movement styles.



Feel free to modify them or create entirely new presets for your own project.



---



## Setup



1. Insert `CharacterController.lua` into `StarterCharacterScripts`.

2. Insert `AttributeCreator.lua` into `ServerScriptService`.

3. Play the game.



That's it.



The controller should work automatically on keyboard, mobile, and gamepad.



---



## Server Integration



The controller supports Humanoid attributes for movement control.



Freeze movement:



```lua

humanoid:SetAttribute("CanMove", false)

```



Restore movement:



```lua

humanoid:SetAttribute("CanMove", true)

```



Apply a speed multiplier:



```lua

humanoid:SetAttribute("MoveMultiplier", 1.5)

```



Slow a player down:



```lua

humanoid:SetAttribute("MoveMultiplier", 0.5)

```



---



## Inspiration



This project was heavily inspired by Blue Skye's Roblox character controller experiments and the idea of improving movement feel while still keeping Humanoid compatibility.



While the implementation is different, Blue Skye's work helped motivate the creation of this controller and many of the ideas explored during development.



---



Feel free to:



* Use it

* Modify it

* Learn from it

* Fork it

* Improve it



---



## Author's Note



A few things worth mentioning:



You may notice that this controller still interacts with certain Humanoid properties such as `WalkSpeed`, `JumpPower`, `JumpHeight`, and related movement settings.



This is intentional. :P



Even though the controller already overrides movement behavior, exposing these settings through the controller makes them easier to configure and understand. The goal was not to fight Roblox's character system (i tried and then regretted it immediately, not going to do that ever again), but to work alongside it while providing more control over movement feel.



This project was also developed with AI-assisted collaboration. Tools such as ChatGPT were used to help debug issues, explore ideas, review code, and discuss architecture. :)



That said, AI did not write the project on its own. Every major change was reviewed, tested, modified, rejected, rewritten, or adapted before becoming part of the controller. Many features, decisions, fixes, and adjustments came from experimentation, testing, and sometimes pure stubbornness from me. (lol)



As with many projects, development was not always graceful (hec, it could've been worse but it got better just over the time). There were bugs, rewrites, dead ends, questionable ideas (ehhhh y'know), and at least one commit containing the words "skill issue" because a problem turned out to be completely self-inflicted. (seriously, i accidentally used the old code and commited it to the rework branch instead 🤦‍♂️)



The controller exists because of a mix of learning, iteration, curiosity, persistence, and a willingness to laugh at mistakes while fixing them... cool right? :D



If you're reading the code, feel free to learn from it, improve it, modify it, or build something entirely different from it. Tbh, it was fun btw and it's my first time making this repo public! ^_^





**ENZO-KYON137 WAS HERE**
