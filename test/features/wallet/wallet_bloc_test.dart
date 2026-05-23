import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';
import 'package:home_tuition_nepal_app/features/wallet/presentation/blocs/wallet_bloc.dart';

void main() {
  group('WalletBloc', () {
    blocTest<WalletBloc, WalletState>(
      'load resolves to ready with balance 1000 and signup ledger entry',
      build: () => WalletBloc(FakeWalletRepository(PlatformSettingsService())),
      act: (b) => b.add(const WalletLoaded('u1')),
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.status, WalletStatus.ready);
        expect(b.state.balance, 1000);
        expect(b.state.entries.length, 1);
        expect(b.state.entries.first.delta, 1000);
      },
    );

    blocTest<WalletBloc, WalletState>(
      'WalletBalanceChanged reloads from the repository',
      build: () {
        final repo = FakeWalletRepository(PlatformSettingsService());
        return WalletBloc(repo);
      },
      act: (b) async {
        b.add(const WalletLoaded('u2'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
        b.add(const WalletBalanceChanged());
      },
      wait: const Duration(milliseconds: 600),
      verify: (b) {
        expect(b.state.status, WalletStatus.ready);
        expect(b.state.balance, 1000);
      },
    );
  });
}
