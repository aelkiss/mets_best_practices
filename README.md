# mets_best_practices
Schematron rules for validating METS best practices

## Using the schema

In oXygen: Document -> Validate -> Validate with: 
OR: Document -> Schema -> Associate Schema: 

URL: `https://raw.githubusercontent.com/mlibrary/mets_best_practices/master/mets_best_practices.sch`
Schema type: Schematron

At the command line, there are a few options. Here are a couple projects that have command-line tools to validate a document against a Schematron schema:

https://github.com/flazz/schematron
https://github.com/NCAR/crux

## Running the tests

```bash
git clone https://github.com/mlibrary/mets_best_practices
cd mets_best_practices
bundle install
bundle exec rspec
```
