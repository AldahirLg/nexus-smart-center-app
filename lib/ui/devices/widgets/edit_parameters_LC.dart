import 'package:flutter/material.dart';
import 'package:nexus_smart_center/models/level_controller_model.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class EditParameterLeveController extends StatefulWidget {
  final ParametersLevelController parameters;

  const EditParameterLeveController({super.key, required this.parameters});

  @override
  State<EditParameterLeveController> createState() =>
      _EditParameterLeveControllerState();
}

class _EditParameterLeveControllerState
    extends State<EditParameterLeveController> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController heightCisternaController;
  late final TextEditingController heightTinacoController;
  late final TextEditingController levelHighController;
  late final TextEditingController levelLowController;
  late final TextEditingController minCisternaController;

  @override
  void initState() {
    super.initState();

    final parameters = widget.parameters;

    heightCisternaController = TextEditingController(
      text: parameters.heightCis.toString(),
    );

    heightTinacoController = TextEditingController(
      text: parameters.heightTin.toString(),
    );

    levelHighController = TextEditingController(
      text: parameters.levelHight.toString(),
    );

    levelLowController = TextEditingController(
      text: parameters.levelLow.toString(),
    );

    minCisternaController = TextEditingController(
      text: parameters.minCis.toString(),
    );
  }

  @override
  void dispose() {
    heightCisternaController.dispose();
    heightTinacoController.dispose();
    levelHighController.dispose();
    levelLowController.dispose();
    minCisternaController.dispose();

    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    return null;
  }

  String? _validatePositive(String? value) {
    final requiredError = _validateRequired(value);

    if (requiredError != null) {
      return requiredError;
    }

    final number = int.tryParse(value!.trim());

    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number <= 0) {
      return 'Debe ser mayor que 0';
    }

    return null;
  }

  String? _validatePercentage(String? value) {
    final requiredError = _validateRequired(value);

    if (requiredError != null) {
      return requiredError;
    }

    final number = int.tryParse(value!.trim());

    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number < 0 || number > 100) {
      return 'Debe estar entre 0 y 100';
    }

    return null;
  }

  String? _validateLevelHigh(String? value) {
    final error = _validatePercentage(value);

    if (error != null) {
      return error;
    }

    final high = int.parse(value!.trim());
    final low = int.tryParse(levelLowController.text.trim());

    if (low != null && high <= low) {
      return 'Debe ser mayor que el nivel bajo';
    }

    return null;
  }

  String? _validateLevelLow(String? value) {
    final error = _validatePercentage(value);

    if (error != null) {
      return error;
    }

    final low = int.parse(value!.trim());
    final high = int.tryParse(levelHighController.text.trim());

    if (high != null && low >= high) {
      return 'Debe ser menor que el nivel alto';
    }

    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parameters = ParametersLevelController(
      heightCis: int.parse(heightCisternaController.text.trim()),
      heightTin: int.parse(heightTinacoController.text.trim()),
      levelHight: int.parse(levelHighController.text.trim()),
      levelLow: int.parse(levelLowController.text.trim()),
      minCis: int.parse(minCisternaController.text.trim()),
    );

    Navigator.of(context).pop(parameters);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.colors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                'Editar configuración',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 20),

              _ConfigField(
                label: 'Altura cisterna (cm)',
                controller: heightCisternaController,
                validator: _validatePositive,
              ),

              const SizedBox(height: 12),

              _ConfigField(
                label: 'Altura tinaco (cm)',
                controller: heightTinacoController,
                validator: _validatePositive,
              ),

              const SizedBox(height: 12),

              _ConfigField(
                label: 'Nivel alto (%)',
                controller: levelHighController,
                validator: _validateLevelHigh,
              ),

              const SizedBox(height: 12),

              _ConfigField(
                label: 'Nivel bajo (%)',
                controller: levelLowController,
                validator: _validateLevelLow,
              ),

              const SizedBox(height: 12),

              _ConfigField(
                label: 'Mínimo cisterna (%)',
                controller: minCisternaController,
                validator: _validatePercentage,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _ConfigField({
    required this.label,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: context.textTheme.bodyLarge,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.tertiary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
