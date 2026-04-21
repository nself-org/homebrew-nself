## Summary
<!-- What does this PR do? Version bump? Formula fix? -->

## Related issue
<!-- Link to the issue this PR addresses, if any. Example: Closes #123 -->

## Type
- [ ] Version bump (automated or manual)
- [ ] Formula bug fix
- [ ] Dependency update
- [ ] CI / tooling

## Testing done

```
# Paste output of:
brew audit --strict Formula/nself.rb
brew install --build-from-source Formula/nself.rb
brew test Formula/nself.rb
```

## Checklist
- [ ] `ruby -c Formula/nself.rb` passes (no syntax errors)
- [ ] `brew audit --strict Formula/nself.rb` passes
- [ ] Formula installs correctly from source
- [ ] `brew test Formula/nself.rb` passes (`nself version` and `nself help` succeed)
- [ ] SHA256 matches the published tarball
- [ ] No AI attribution in commits or PR description
