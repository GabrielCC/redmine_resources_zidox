# Redmine Resources

Zidox specific integration for Redmine.

# Install

Clone the repository in the `plugins` direcotry, run migrations and restart
redmine:
```
git clone git@github.com:ZitecCOM/redmine_resources.git
rake redmine:plugins:migrate NAME=redmine_resources
```

# Configure

1. Go to "Administration > Custom fields" and create a new issue custom field,
format Integer. Set its trackers to the ones you want to recieve resource
estimations and make it avalialbe for which projects your heart desiers.
2. Go to "Administration > Plugins > Redmine Resources - Configure" and choose
the default values.
3. On individual projects you can go to "Settings > Resources" and override the
defaults.

# Run tests

Make sure you have the testing gems plugin:
```
git clone git@github.com:ZitecCOM/redmine_testing_gems.git
bundle install
```

Then run:
```
rake redmine:plugins:spec RAILS_ENV=test NAME=redmine_resources
```

To view test coverage go to `plugins/redmine_resources/tmp/coverage`
and open `index.html` in a browser.

## License

This plugin is covered by the BSD license, see [LICENSE](LICENSE) for details.
