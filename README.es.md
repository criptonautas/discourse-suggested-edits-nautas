# discourse-suggested-edits-nautas

[ENGLISH](README.md) | **ESPAÑOL**

Mantenido por Criptonautas. Sin afiliación ni respaldo de Discourse (Civilized Discourse Construction Kit, Inc.).

Fork de [discourse/discourse-suggested-edits](https://github.com/discourse/discourse-suggested-edits), el plugin experimental de ediciones sugeridas. Upstream lo marca como experimental y no apto para producción.

## Qué cambia este fork

- **Varias sugerencias por post.** Aplicar una sugerencia ya no marca como obsoletas todas las demás sugerencias pendientes del post. Las que cambian otras líneas pasan a la versión nueva; solo quedan obsoletas las que tocan las mismas líneas. Este cambio está propuesto upstream.
- **Revisiones seguras.** Se rechaza una revisión guardada desde un composer abierto antes de que su sugerencia pasara a la versión nueva, así no puede deshacer el cambio recién aplicado.
- Plugin renombrado a `discourse-suggested-edits-nautas`. Instalalo en un directorio con ese nombre.

## Instalación

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/criptonautas/discourse-suggested-edits-nautas.git
```

## Documentación de upstream

Permite a los miembros de la comunidad sugerir ediciones a los primeros posts de categorías o etiquetas configuradas. Los revisores designados pueden aceptar, rechazar o elegir cambios individuales antes de aplicarlos al post.

### Cómo funciona

**Sugerir una edición**: los miembros del grupo configurado para sugerir ven un botón "Suggest Edit" en los primeros posts habilitados. Al pulsarlo se abre el composer con el contenido original del post. Tras hacer los cambios (y opcionalmente indicar un motivo), el usuario envía la sugerencia. El plugin separa los cambios en bloques individuales automáticamente.

**Revisar sugerencias**: los revisores (miembros del grupo revisor, o el autor del post) ven un aviso y un contador de sugerencias pendientes. El modal de revisión muestra cada sugerencia con diffs en línea. Los revisores pueden aceptar o rechazar cambios uno por uno, y luego aplicar los aceptados o descartar la sugerencia entera.

**Revisar / retirar**: el autor de una sugerencia puede revisarla o retirarla antes de que un revisor actúe.

**Obsolescencia**: cuando un revisor aplica una sugerencia, las demás sugerencias pendientes del mismo post pasan a la versión nueva, salvo las que cambian las mismas líneas; esas quedan obsoletas y no se pueden aplicar. Cualquier otra edición del post deja obsoletas todas sus sugerencias pendientes. Se rechaza una revisión guardada desde un composer abierto antes de que su sugerencia pasara a la versión nueva, así el autor la reabre sobre el texto actual.

### Configuración

Activá el plugin y configuralo en Admin > Settings:

| Ajuste | Descripción | Por defecto |
|---|---|---|
| `suggested_edits_enabled` | Interruptor general | `false` |
| `suggested_edits_suggest_groups` | Grupos cuyos miembros pueden sugerir ediciones | — |
| `suggested_edits_review_groups` | Grupos cuyos miembros pueden revisar y aplicar ediciones (el autor del post siempre puede revisar) | — |
| `suggested_edits_included_categories` | Categorías donde se puede sugerir | — |
| `suggested_edits_included_tags` | Etiquetas donde se puede sugerir (se suman a las categorías) | — |
| `suggested_edits_max_creates_per_minute` | Límite de sugerencias creadas por minuto | `5` |
| `suggested_edits_max_revisions_per_minute` | Límite de revisiones por minuto | `10` |

### Restricciones

- Solo se pueden sugerir ediciones a primeros posts.
- Un usuario puede tener como máximo una sugerencia pendiente por post.
- El texto sugerido debe ser distinto del original y respetar el ajuste `min_first_post_length`.

### Mantenimiento de dependencias

`package.json`/`pnpm-lock.yaml` y `Gemfile`/`Gemfile.lock` en la raíz son herramientas de desarrollo para lint y chequeo de tipos, no dependencias del plugin en ejecución. Discourse aporta las dependencias de ejecución.

Desde este repositorio, revisá los dos árboles de dependencias de desarrollo:

```bash
pnpm install --frozen-lockfile
pnpm audit
gem install bundler-audit --no-document
bundler-audit check --update
pnpm lint
```

Mantené TypeScript instalado explícitamente acá: el chequeador de templates necesita la API del compilador de TypeScript 5 y no debe tomar un compilador incompatible de un checkout de Discourse superior.

El workflow dependency-checks corre las auditorías en cada pull request y una vez por semana. Dependabot también revisa semanalmente las herramientas de lint de JavaScript y Ruby y las actions de los workflows. Resolvé las alertas actualizando el árbol de dependencias afectado, no silenciándolas ni borrando los lockfiles.

Al cambiar dependencias, corré también los tests de Rails, de navegador y de JavaScript del plugin desde un checkout de Discourse:

```bash
LOAD_PLUGINS=1 bin/rspec plugins/discourse-suggested-edits-nautas/spec
bin/qunit plugins/discourse-suggested-edits-nautas/test/javascripts
```

### Automatización

Este plugin no incluye un servidor MCP propio ni un agente de actualización de documentación. Las sugerencias se pueden gestionar con la API HTTP del plugin. Cualquier herramienta MCP futura debería integrarse con el MCP compartido de Discourse en vez de sumar un servidor aparte acá.

## Licencia

MIT (upstream: Sam). Modificaciones © 2026 Criptonautas. Consultá [LICENSE](LICENSE).

Nuestros agregados a este README están bajo [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt); el texto del proyecto original conserva su licencia.
