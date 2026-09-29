@testable import IncomesLibrary
import Testing

struct IncomesFileSchemaCouplingTests {
    @Test
    func export_writes_the_latest_storage_schema_version() {
        #expect(
            IncomesFileCodec.currentSchemaVersion
                == IncomesSchemaMigrationPlan.schemas.last?.versionIdentifier
        )
    }

    @Test
    func every_schema_since_the_first_file_version_has_a_reader() {
        // A key path to this existential metatype member crashes the Swift 6.4 compiler.
        // swiftlint:disable:next prefer_key_path
        let fileEraVersions = IncomesSchemaMigrationPlan.schemas.map { schema in
            schema.versionIdentifier
        }
        .filter { version in
            version >= IncomesFileCodec.firstSchemaVersion
        }
        #expect(Set(fileEraVersions) == Set(IncomesFileCodec.readableSchemaVersions))
    }
}
