//
//  SwifQLable+Execute.swift
//  SwifQLVapor
//
//  Created by Mihael Isaev on 12/12/2018.
//

import SwifQL
import SQL
import DatabaseKit
import PostgreSQL
import MySQL

extension SwifQLable {
    public func execute<C>(on conn: C) -> SQLRawBuilder<C> where C: PostgreSQLConnection {
        return execute(on: conn, as: .psql)
    }
    
    public func execute<C>(on conn: C) -> SQLRawBuilder<C> where C: MySQLConnection {
        return execute(on: conn, as: .mysql)
    }
    
    fileprivate func execute<C>(on conn: C, as dialect: SQLDialect) -> SQLRawBuilder<C> where C: SQLConnectable {
        let prepared = prepare(dialect).splitted
        return conn.raw(prepared.query).binds(prepared.values)
    }
    
    public func execute<D: PostgreSQLDatabase>(on container: Container, as identifier: DatabaseKit.DatabaseIdentifier<D>) -> Future<SQLRawBuilder<D.Connection>> {
        return container.requestPooledConnection(to: identifier).flatMap { conn in
            defer { try? container.releasePooledConnection(conn, to: identifier) }
            return container.eventLoop.newSucceededFuture(result: self.execute(on: conn))
        }
    }
    
    public func execute<D: MySQLDatabase>(on container: Container, as identifier: DatabaseKit.DatabaseIdentifier<D>) -> Future<SQLRawBuilder<D.Connection>> {
        return container.requestPooledConnection(to: identifier).flatMap { conn in
            defer { try? container.releasePooledConnection(conn, to: identifier) }
            return container.eventLoop.newSucceededFuture(result: self.execute(on: conn))
        }
    }
}
