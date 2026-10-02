import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Lee el código de barras del envase con la cámara y devuelve el número.
///
/// Se abre con `Navigator.push<String>` y retorna el código leído, o `null`
/// si el tendero cerró la pantalla. También ofrece escribirlo a mano: los
/// códigos borrosos o despegados son el pan de cada día en una tienda.
class EscanerPantalla extends StatefulWidget {
  const EscanerPantalla({super.key});

  @override
  State<EscanerPantalla> createState() => _EscanerPantallaState();
}

class _EscanerPantallaState extends State<EscanerPantalla> {
  final _controlador = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
    ],
  );

  // Evita que dos lecturas seguidas cierren la pantalla dos veces.
  bool _entregado = false;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _entregar(String codigo) {
    if (_entregado || codigo.trim().isEmpty) return;
    _entregado = true;
    Navigator.of(context).pop(codigo.trim());
  }

  void _alDetectar(BarcodeCapture captura) {
    for (final codigo in captura.barcodes) {
      final valor = codigo.rawValue;
      if (valor != null && valor.trim().isNotEmpty) {
        _entregar(valor);
        return;
      }
    }
  }

  Future<void> _escribirAMano() async {
    final ctrl = TextEditingController();
    final codigo = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Escribir el código'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Código de barras',
            hintText: '7750243011408',
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text),
            child: const Text('Usar'),
          ),
        ],
      ),
    );
    if (codigo != null) _entregar(codigo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear producto'),
        actions: [
          IconButton(
            tooltip: 'Linterna',
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => _controlador.toggleTorch(),
          ),
          IconButton(
            tooltip: 'Cambiar cámara',
            icon: const Icon(Icons.cameraswitch_outlined),
            onPressed: () => _controlador.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controlador,
            onDetect: _alDetectar,
            errorBuilder: (context, error) => _SinCamara(
              detalle: _mensajeDeError(error),
              alEscribir: _escribirAMano,
            ),
          ),
          const _MiraDeEscaneo(),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Apunta al código de barras del envase',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _escribirAMano,
                      icon: const Icon(Icons.keyboard_outlined,
                          color: Colors.white),
                      label: const Text(
                        'Escribirlo a mano',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _mensajeDeError(MobileScannerException error) =>
      switch (error.errorCode) {
        MobileScannerErrorCode.permissionDenied =>
          'La app necesita permiso de cámara para leer códigos.',
        MobileScannerErrorCode.unsupported =>
          'Este dispositivo no puede escanear códigos.',
        _ => 'No se pudo abrir la cámara.',
      };
}

class _SinCamara extends StatelessWidget {
  const _SinCamara({required this.detalle, required this.alEscribir});

  final String detalle;
  final VoidCallback alEscribir;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  size: 56, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                detalle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: alEscribir,
                icon: const Icon(Icons.keyboard_outlined),
                label: const Text('Escribir el código'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recuadro guía: ayuda a encuadrar y deja claro dónde poner el envase.
class _MiraDeEscaneo extends StatelessWidget {
  const _MiraDeEscaneo();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 260,
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white70, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
