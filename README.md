## Le but de ce projet est de mettre en place un planificateur de déplacements dans une base martienne..

Une base martienne est composée de modules tous suffisamment spacieux pour contenir la totalité de la colonie. Le passage entre deux modules se fera via un système de tunnels de longueurs variables et ne permettant chacun que le passage d'une personne à la fois. Bien entendu, nous désirons que le système s'adapte à tout plan de base que nous lui soumettrons.

### Notre colonie se développera en trois étapes :

1. dans un premier temps, pour des problèmes de sécurité, notre colonie sera réduite à un seul individu,
2. dans un second temps, le développement aidant, de nombreux individus peupleront notre colonie mais le système aura la simple tâche de réguler leurs déplacements.
3. enfin, la capacité de calcul aidant, le système devra permettre la planification totale des déplacements.


## Informations techniques : 

Ce projet utilise `Dune` pour compiler et non `Makefile`.

```{bash}
$ opam init
$ opam install dune
```

### Build your project with:

`dune build`

### Run your tests with:

`dune test`

Run your program with:

`dune exec project_name`



## Arborescence du projet : 

- Dans **/bin** :

L'executable principal `main.ml`

- Dans **/lib** : 

Les modules et leurs interfaces