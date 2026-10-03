package com.pichiplayer.data.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(
    entities = [
        VideoEntity::class,
        FolderEntity::class,
        SearchHistoryEntity::class
    ],
    version = 1,
    exportSchema = false
)
abstract class PichiDatabase : RoomDatabase() {
    abstract fun videoDao(): VideoDao
    abstract fun folderDao(): FolderDao
    abstract fun searchHistoryDao(): SearchHistoryDao

    companion object {
        @Volatile
        private var INSTANCE: PichiDatabase? = null

        fun getInstance(context: Context): PichiDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    PichiDatabase::class.java,
                    "pichi_player.db"
                ).fallbackToDestructiveMigration().build()
                INSTANCE = instance
                instance
            }
        }
    }
}
