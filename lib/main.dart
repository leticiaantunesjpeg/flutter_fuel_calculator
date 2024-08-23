import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(CalculadoraCombustivel());
}

class CalculadoraCombustivel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Combustível',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
      ),
      home: CalculadoraDeCombustivel(),
    );
  }
}

class CalculadoraDeCombustivel extends StatefulWidget {
  @override
  _CalculadoraDeCombustivelState createState() =>
      _CalculadoraDeCombustivelState();
}

class _CalculadoraDeCombustivelState extends State<CalculadoraDeCombustivel> {
  final TextEditingController _controllerAlcool = TextEditingController();
  final TextEditingController _controllerGasolina = TextEditingController();
  String _erroAlcool = '';
  String _erroGasolina = '';

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

  void _calcular() {
    final String alcoolText = _controllerAlcool.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final String gasolinaText = _controllerGasolina.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final double? precoAlcool = double.tryParse(alcoolText);
    final double? precoGasolina = double.tryParse(gasolinaText);

    setState(() {
      _erroAlcool =
          precoAlcool == null ? 'Insira um valor válido para o álcool.' : '';
      _erroGasolina = precoGasolina == null
          ? 'Insira um valor válido para a gasolina.'
          : '';
    });

    if (precoAlcool == null || precoGasolina == null || precoGasolina == 0) {
      return;
    }

    final double razao = precoAlcool / precoGasolina;

    _showAlertDialog(
      'Resultado',
      razao < 0.7 ? 'Abasteça com Álcool' : 'Abasteça com Gasolina',
    );
  }

  void _limpar() {
    _controllerAlcool.clear();
    _controllerGasolina.clear();
    setState(() {
      _erroAlcool = '';
      _erroGasolina = '';
    });
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Combustível'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(
              controller: _controllerAlcool,
              labelText: 'Preço do Álcool',
              icon: Icons.monetization_on,
              errorText: _erroAlcool,
            ),
            const SizedBox(height: 20.0),
            _buildTextField(
              controller: _controllerGasolina,
              labelText: 'Preço da Gasolina',
              icon: Icons.monetization_on,
              errorText: _erroGasolina,
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildElevatedButton(
                  onPressed: _calcular,
                  text: 'Calcular',
                  color: Colors.blue,
                ),
                _buildElevatedButton(
                  onPressed: _limpar,
                  text: 'Limpar',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: labelText,
          errorText: errorText.isNotEmpty ? errorText : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            final numericValue = value
                .replaceAll('R\$', '')
                .replaceAll('.', '')
                .replaceAll(',', '.');
            final double? parsedValue = double.tryParse(numericValue);
            if (parsedValue != null) {
              final formattedValue = _currencyFormat.format(parsedValue);
              controller.value = controller.value.copyWith(
                text: formattedValue.replaceAll('R\$', ''),
                selection:
                    TextSelection.collapsed(offset: formattedValue.length),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildElevatedButton({
    required VoidCallback onPressed,
    required String text,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(text),
    );
  }
}
