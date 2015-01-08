GraphFinder
==========

GraphFinder is a ruby class to find the graphs that match a graph pattern in a flexible way.
It assumes that the content of a SPARQL endpoint is accessible only through SPARQL queries, i.e., the entire graphs are not accessible. Thus, instead of implementing a graph search algorithm, it generates a series of SPARQL queries and consults the SPARQL endpoint with them.

It is a generalization of RelFinder.
It does not include graphical rendering.

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

Future Works
------------

* To implements a REST service.
* To make it find paths across multiple endpoints.

AUTHOR(S)
---------

* Jin-Dong Kim, Database Center for Life Science

License
-------

Released under the MIT license (http://opensource.org/licenses/MIT).
