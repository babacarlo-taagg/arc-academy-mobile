import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';

/// Pavé de chiffres à gros boutons pour le code secret (4 à 6 chiffres), sans clavier du système.
class PavePin extends StatefulWidget {
  const PavePin({super.key, required this.onValider, this.longueurMax = 6, this.longueurMin = 4, this.actif = true});

  final void Function(String pin) onValider;
  final int longueurMin;
  final int longueurMax;
  final bool actif;

  @override
  State<PavePin> createState() => PavePinState();
}

class PavePinState extends State<PavePin> {
  String _saisie = '';

  void vider() => setState(() => _saisie = '');

  void _ajouter(String c) {
    if (!widget.actif || _saisie.length >= widget.longueurMax) return;
    setState(() => _saisie += c);
    if (_saisie.length == widget.longueurMax) widget.onValider(_saisie);
  }

  void _effacer() {
    if (_saisie.isEmpty) return;
    setState(() => _saisie = _saisie.substring(0, _saisie.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    Widget touche(String libelle, {VoidCallback? onTap, Widget? enfant, String? semantique}) => Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 84,
        height: 64,
        child: Semantics(
          button: true,
          label: semantique ?? libelle,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: ArcCouleurs.ligne),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.actif ? onTap : null,
              child: Center(
                child: enfant ?? Text(libelle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${_saisie.length} / ${widget.longueurMax}',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.longueurMax; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _saisie.length ? ArcCouleurs.primaire : Colors.transparent,
                    border: Border.all(
                      color: i < widget.longueurMin || i < _saisie.length ? ArcCouleurs.primaire : ArcCouleurs.ligne,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (final ligne in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final c in ligne) touche(c, onTap: () => _ajouter(c))],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            touche(
              '',
              semantique: t.pinEffacer,
              onTap: _effacer,
              enfant: const Icon(Icons.backspace_outlined, size: 28),
            ),
            touche('0', onTap: () => _ajouter('0')),
            touche(
              t.pinValider,
              onTap: _saisie.length >= widget.longueurMin ? () => widget.onValider(_saisie) : null,
              enfant: Icon(
                Icons.check_rounded,
                size: 32,
                color: _saisie.length >= widget.longueurMin ? ArcCouleurs.primaire : ArcCouleurs.ligne,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
