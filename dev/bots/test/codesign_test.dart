// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('mac-os')
library;

import '../../../packages/flutter_tools/test/src/fake_process_manager.dart';
import '../test.dart';
import './common.dart';

void main() async {
  const String flutterRoot = '/a/b/c';
  final List<String> allExpectedFiles = await binariesWithEntitlements(flutterRoot) + await binariesWithoutEntitlements(flutterRoot);
  final String allFilesStdout = allExpectedFiles.join('\n');
  final List<String> withEntitlements = await binariesWithEntitlements(flutterRoot);

  group('verifyExist', () {
    test('Not all files found', () async {
      final ProcessManager processManager = FakeProcessManager.list(
        <FakeCommand>[
          const FakeCommand(
            command: <String>[
              'find',
              '/a/b/c/bin/cache',
              '-type',
              'f',
            ],
            stdout: '/a/b/c/bin/cache/artifacts/engine/android-arm-profile/darwin-x64/gen_snapshot',
          ),
          const FakeCommand(
            command: <String>[
              'file',
              '--mime-type',
              '-b',
              '/a/b/c/bin/cache/artifacts/engine/android-arm-profile/darwin-x64/gen_snapshot',
            ],
            stdout: 'application/x-mach-binary',
          ),
        ],
      );
      expect(
        () async => verifyExist(flutterRoot, processManager: processManager),
        throwsExceptionWith('Did not find all expected binaries!'),
      );
    });

    test('All files found', () async {
      final List<FakeCommand> commandList = <FakeCommand>[];
      final FakeCommand findCmd = FakeCommand(
        command: const <String>[
          'find',
          '$flutterRoot/bin/cache',
          '-type',
          'f',],
        stdout: allFilesStdout,
          );
      commandList.add(findCmd);
      for (final String expectedFile in allExpectedFiles) {
        commandList.add(
          FakeCommand(
            command: <String>[
              'file',
              '--mime-type',
              '-b',
              expectedFile,
            ],
            stdout: 'application/x-mach-binary',
          )
        );
      }
      final ProcessManager processManager = FakeProcessManager.list(commandList);
      await expectLater(verifyExist('/a/b/c', processManager: processManager), completes);
    });
  });

  group('findBinaryPaths', () {
    test('All files found', () async {
      final List<FakeCommand> commandList = <FakeCommand>[];
      final FakeCommand findCmd = FakeCommand(
        command: const <String>[
          'find',
          '$flutterRoot/bin/cache',
          '-type',
          'f',],
        stdout: allFilesStdout,
      );
      commandList.add(findCmd);
      for (final String expectedFile in allExpectedFiles) {
        commandList.add(
          FakeCommand(
            command: <String>[
              'file',
              '--mime-type',
              '-b',
              expectedFile,
            ],
            stdout: 'application/x-mach-binary',
          )
        );
      }
      final ProcessManager processManager = FakeProcessManager.list(commandList);
      final List<String> foundFiles = await findBinaryPaths('$flutterRoot/bin/cache', processManager: processManager);
      expect(foundFiles, allExpectedFiles);
    });

    test('Empty file list', () async {
      final List<FakeCommand> commandList = <FakeCommand>[];
      const FakeCommand findCmd = FakeCommand(
        command: <String>[
          'find',
          '$flutterRoot/bin/cache',
          '-type',
          'f',],
      );
      commandList.add(findCmd);
      final ProcessManager processManager = FakeProcessManager.list(commandList);
      final List<String> foundFiles = await findBinaryPaths('$flutterRoot/bin/cache', processManager: processManager);
      expect(foundFiles, <String>[]);
  });

  group('isBinary', () {
    test('isTrue', () async {
      final List<FakeCommand> commandList = <FakeCommand>[];
      const String fileToCheck = '/a/b/c/one.zip';
      const FakeCommand findCmd = FakeCommand(
        command: <String>[
          'file',
          '--mime-type',
          '-b',
          fileToCheck,
        ],
        stdout: 'application/x-mach-binary',
      );
      commandList.add(findCmd);
      final ProcessManager processManager = FakeProcessManager.list(commandList);
      final bool result = await isBinary(fileToCheck, processManager: processManager);
      expect(result, isTrue);
    });

    test('isFalse', () async {
      final List<FakeCommand> commandList = <FakeCommand>[];
      const String fileToCheck = '/a/b/c/one.zip';
      const FakeCommand findCmd = FakeCommand(
        command: <String>[
          'file',
          '--mime-type',
          '-b',
          fileToCheck,
        ],
        stdout: 'text/xml',
      );
      commandList.add(findCmd);
      final ProcessManager processManager = FakeProcessManager.list(commandList);
      final bool result = await isBinary(fileToCheck, processManager: processManager);
      expect(result, isFalse);
    });
  });

  group('hasExpectedEntitlements', () {
     test('expected entitlements', () async {
       final List<FakeCommand> commandList = <FakeCommand>[];
       const String fileToCheck = '/a/b/c/one.zip';
       const FakeCommand codesignCmd = FakeCommand(
         command: <String>[
           'codesign',
           '--display',
           '--entitlements',
           ':-',
           fileToCheck,
         ],
       );
       commandList.add(codesignCmd);
       final ProcessManager processManager = FakeProcessManager.list(commandList);
       final bool result = await hasExpectedEntitlements(fileToCheck, flutterRoot, processManager: processManager);
       expect(result, isTrue);
     });

     test('unexpected entitlements', () async {
       final List<FakeCommand> commandList = <FakeCommand>[];
       const String fileToCheck = '/a/b/c/one.zip';
       const FakeCommand codesignCmd = FakeCommand(
         command: <String>[
           'codesign',
           '--display',
           '--entitlements',
           ':-',
           fileToCheck,
         ],
         exitCode: 1,
       );
       commandList.add(codesignCmd);
       final ProcessManager processManager = FakeProcessManager.list(commandList);
       final bool result = await hasExpectedEntitlements(fileToCheck, flutterRoot, processManager: processManager);
       expect(result, isFalse);
     });
    });
  });

  group('verifySignatures', () {

    test('succeeds if every binary is codesigned and has correct entitlements', () async {
      final List<FakeCommand> commandList = <FakeCommand>[];
      final FakeCommand findCmd = FakeCommand(
        command: const <String>[
          'find',
          '$flutterRoot/bin/cache',
          '-type',
          'f',],
        stdout: allFilesStdout,
          );
      commandList.add(findCmd);
      for (final String expectedFile in allExpectedFiles) {
        commandList.add(
          FakeCommand(
            command: <String>[
              'file',
              '--mime-type',
              '-b',
              expectedFile,
            ],
            stdout: 'application/x-mach-binary',
          )
        );
      }
      for (final String expectedFile in allExpectedFiles) {
        commandList.add(
          FakeCommand(
            command: <String>[
              'codesign',
              '-vvv',
              expectedFile,
            ],
          )
        );
        if (withEntitlements.contains(expectedFile)) {
          commandList.add(
            FakeCommand(
              command: <String>[
                'codesign',
                '--display',
                '--entitlements',
                ':-',
                expectedFile,
              ],
              stdout: expectedEntitlements.join('\n'),
            )
          );
        }
      }
      final ProcessManager processManager = FakeProcessManager.list(commandList);
      await expectLater(verifySignatures(flutterRoot, processManager: processManager), completes);
    });

    test('fails if binaries do not have the right entitlements', () async {
      final List<FakeCommand> commandList = <FakeCommand>[];
      final FakeCommand findCmd = FakeCommand(
        command: const <String>[
          'find',
          '$flutterRoot/bin/cache',
          '-type',
          'f',],
        stdout: allFilesStdout,
          );
      commandList.add(findCmd);
      for (final String expectedFile in allExpectedFiles) {
        commandList.add(
          FakeCommand(
            command: <String>[
              'file',
              '--mime-type',
              '-b',
              expectedFile,
            ],
            stdout: 'application/x-mach-binary',
          )
        );
      }
      for (final String expectedFile in allExpectedFiles) {
        commandList.add(
          FakeCommand(
            command: <String>[
              'codesign',
              '-vvv',
              expectedFile,
            ],
          )
        );
        if (withEntitlements.contains(expectedFile)) {
          commandList.add(
            FakeCommand(
              command: <String>[
                'codesign',
                '--display',
                '--entitlements',
                ':-',
                expectedFile,
              ],
            )
          );
        }
      }
      final ProcessManager processManager = FakeProcessManager.list(commandList);

      expect(
        () async => verifySignatures(flutterRoot, processManager: processManager),
        throwsExceptionWith('Test failed because files found with the wrong entitlements'),
      );
    });
  });
}
