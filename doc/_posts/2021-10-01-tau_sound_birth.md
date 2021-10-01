---
title:  "&tau; Sound is born"
published: true
permalink: tau_sound_birth-post.html
summary: "&tau; Sound is born!"
tags: [news]
---
## τ Sound 9.0 is born

Flutter Sound 8.3 was published under the LGPL License.

This was a big problem : someone noticed that the LGPL License
does not allow static links to the library.

But the Flutter plugins are statically linked to the App.
This means that all the Apps using Flutter Sound and published under a proprietary/close source License
was  in violation for the LGPL License.

To solve this issue, Flutter Sound 8.3 has been forked into two branches :
- [Flutter Sound 8.4](https://tau.canardoux.xyz/readme.html), which is published under the permissive Mozilla License : MPL2.0
- Tau Sound 9.0 (this fork), which is published under a pure GPL license.

Which of those two forks should you use ?

- If your App can be published under the GPL license, Tau Sound 9.0 is the good choice : 
this fork has (and will have) many enhancements compared to Flutter Sound.
- If you cannot (or don't want to) publish your App under the GPL License,
you can consider using the [Flutter Sound 8.4](https://tau.canardoux.xyz/readme.html) branch.

## Have a good life, &tau; Sound
