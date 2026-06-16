import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class IGetAccountsUseCase
    implements IUseCase<ListAccountResult, NoParams> {}

abstract interface class ISaveAccountUseCase
    implements IUseCase<VoidResult, AccountParams> {}

abstract interface class IDeleteAccountUseCase
    implements IUseCase<VoidResult, AccountIdParams> {}

abstract interface class IUpdateAccountUseCase
    implements IUseCase<VoidResult, AccountParams> {}
