# mets_best_practices
Schematron rules for validating METS best practices

## Using the schema

In oXygen: Document -> Validate -> Validate with: 
OR: Document -> Schema -> Associate Schema: 

- URL: `https://raw.githubusercontent.com/mlibrary/mets_best_practices/master/mets_best_practices.sch`
- Schema type: Schematron

FIXME: How to run with Saxon-HE at the command line?

## Running the tests

```bash

- Download Saxon-HE: https://sourceforge.net/projects/saxon/files/Saxon-HE/ (only 9.7 is known to work)

- Download XSpec: https://github.com/xspec/xspec - follow the instructions under Getting Started to download and set the path to Saxon

Run XSpec:
```
/path/to/xspec.sh -s mets_best_practices.xspec
```
