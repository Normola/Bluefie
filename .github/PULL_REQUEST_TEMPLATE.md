## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Performance improvement
- [ ] Test coverage improvement

## Testing
- [ ] Tests pass locally
- [ ] New tests added for changes (if applicable)
- [ ] Manual testing completed

## APK Size Impact
Our CI now validates **Release APK** size (what users download) rather than Profile APK size:
- **Release APK limit**: 50MB (production builds)
- **Profile APK**: No limit (includes debug symbols for performance testing)

The build validation will report both sizes for transparency.

## Checklist
- [ ] Code follows project style guidelines (no else statements, minimal nesting)
- [ ] Self-review completed
- [ ] Documentation updated (if needed)
- [ ] No breaking changes to existing functionality
