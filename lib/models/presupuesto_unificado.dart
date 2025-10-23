class PresupuestoUnificado {
  final String id;
  final String nombre;
  final String tipo;
  final Map<String, double> categorias;

  PresupuestoUnificado({
    String? id,
    required this.nombre,
    required this.tipo,
    required this.categorias,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'tipo': tipo,
    'categorias': categorias,
  };

  static PresupuestoUnificado fromMap(Map<String, dynamic> m) {
    final cats = <String, double>{};
    (m['categorias'] as Map<String, dynamic>?)?.forEach(
      (k, v) => cats[k] = (v as num).toDouble(),
    );
    final id = (m['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
        .toString();
    return PresupuestoUnificado(
      id: id,
      nombre: m['nombre'] ?? '',
      tipo: m['tipo'] ?? 'Mensual',
      categorias: cats,
    );
  }
}
