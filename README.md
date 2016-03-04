GraphFinder
==========

GraphFinder is a ruby class of which the instances are to find subgraphs from a RDF graph in a very flexible way.
It assumes that an RDF graph is accessible only through SPARQL, i.e., the entire graphs are not accessible. Thus, instead of implementing a normal graph search algorithm, it generates a bunch of SPARQL queries to consults the SPARQL endpoint with.

It is a generalization of the RelFinder algorithm.

For details of the operation, you are referred to
* Jin-Dong Kim and Kevin Bretonnel Cohen, “Triple Pattern Variation Operations for Flexible Graph Search”, Proceedings of the 1st international workshop on Natural Language Interfaces for Web of Data (NLIWoD), 2014. [link](https://docs.google.com/viewer?a=v&pid=sites&srcid=ZGVmYXVsdGRvbWFpbnxubGl3b2QyMDE0fGd4OjYyYjVkNTU2MjVjYjUyMzI)

Initialize
----------

* URL of a SPARQL endpoint
* options to be passed to the endpoint

Input
-----

* apgp: anchored PGP
* template: eSPARQL template

Output
------

* Variation of SPARQL queries that represents the APGP and template.

Author
------

* [Jin-Dong Kim](http://data.dbcls.jp/~jdkim/)

License
-------

Released under the [MIT license](http://opensource.org/licenses/MIT).
