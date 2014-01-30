find . -name \*.m | grep -v AFNetworking | xargs genstrings -s NSLocalizedStringWithDefaultValue -o en.lproj/
