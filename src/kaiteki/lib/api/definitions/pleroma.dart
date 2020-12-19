import 'package:kaiteki/api/adapters/pleroma/adapter.dart';
import 'package:kaiteki/api/api_type.dart';
import 'package:kaiteki/api/definitions/definitions.dart';
import 'package:kaiteki/app_colors.dart';

class PleromaApiDefinition extends ApiDefinition<PleromaAdapter> {
  @override
  String get name => 'Pleroma';

  @override
  ApiType get type => ApiType.Pleroma;

  @override
  PleromaAdapter createAdapter() => PleromaAdapter();

  @override
  ApiTheme get theme {
    return ApiTheme(
      backgroundColor: AppColors.pleromaSecondary,
      primaryColor: AppColors.pleromaPrimary,
      iconAssetLocation: 'assets/icons/pleroma.png',
    );
  }
}
