# So what is this?

A set of standard Capistrano/Rake tasks to use with WordPress, Magento and MODx projects.

## Getting started
1. Merge this into an existing project
2. Create dev.rb, preprod.rb and prod.rb in config/deploy and adjust accordingly - see .SAMPLE.rb for reference
3. Add relevant deploy keys to the keys directory (check out Github's notes on deployment keys)

## Branches &amp; tags

<table>
<tr><th>Purpose</th><th>Prefix</th><th>Version Tag</th><th>Example</th></tr>
<tr><td>Customer</td><td>c/</td><td>&nbsp;</td><td>c/lpp</td></tr>
<tr><td>Stock themes</td><td>t/</td><td>t/openhouse/2.87</td><td>t/openhouse</td></tr>
<tr><td>Upstream</td><td>n/a</td><td>u/3.1.2</td><td>upstream</td></tr>
</table>

## Features
* Set up a proper remote environment (deploy keys, bash prompt, mysql setup)
* Deploy WordPress and Magento projects

## TODO
* add tasks to download the deployed theme - needed for migrating old themes to this setup
* add support for loading a 'seed.sql' file
* add cron jobs for backing up uploads and db automatically + fetching?
* tool to fetch new plugins
* MODx support
