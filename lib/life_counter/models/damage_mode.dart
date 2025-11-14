enum DamageMode {
  damage("Damage"),
  healing("Healing"),
  lifelink("Lifelink"),
  infect("Infect");

  final String label;

  const DamageMode(this.label);
}
