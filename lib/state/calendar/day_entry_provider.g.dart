// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_entry_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(monthEntries)
const monthEntriesProvider = MonthEntriesFamily._();

final class MonthEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<DateTime, DayEntryModel>>,
          Map<DateTime, DayEntryModel>,
          Stream<Map<DateTime, DayEntryModel>>
        >
    with
        $FutureModifier<Map<DateTime, DayEntryModel>>,
        $StreamProvider<Map<DateTime, DayEntryModel>> {
  const MonthEntriesProvider._({
    required MonthEntriesFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'monthEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthEntriesHash();

  @override
  String toString() {
    return r'monthEntriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<DateTime, DayEntryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<DateTime, DayEntryModel>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return monthEntries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthEntriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthEntriesHash() => r'1670c0142fa9e9855838a1ccfe5d2596b4d26410';

final class MonthEntriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<DateTime, DayEntryModel>>,
          DateTime
        > {
  const MonthEntriesFamily._()
    : super(
        retry: null,
        name: r'monthEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthEntriesProvider call(DateTime start) =>
      MonthEntriesProvider._(argument: start, from: this);

  @override
  String toString() => r'monthEntriesProvider';
}

@ProviderFor(dayEntry)
const dayEntryProvider = DayEntryFamily._();

final class DayEntryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DayEntryModel?>,
          DayEntryModel?,
          Stream<DayEntryModel?>
        >
    with $FutureModifier<DayEntryModel?>, $StreamProvider<DayEntryModel?> {
  const DayEntryProvider._({
    required DayEntryFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'dayEntryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayEntryHash();

  @override
  String toString() {
    return r'dayEntryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DayEntryModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DayEntryModel?> create(Ref ref) {
    final argument = this.argument as DateTime;
    return dayEntry(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayEntryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayEntryHash() => r'8455714546a0314eddcb3d7861fcaa5fb37b7f76';

final class DayEntryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DayEntryModel?>, DateTime> {
  const DayEntryFamily._()
    : super(
        retry: null,
        name: r'dayEntryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DayEntryProvider call(DateTime date) =>
      DayEntryProvider._(argument: date, from: this);

  @override
  String toString() => r'dayEntryProvider';
}
