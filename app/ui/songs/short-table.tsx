import Image from 'next/image';
import { PlaySong, DeleteSong } from '@/app/ui/songs/buttons';
import InvoiceStatus from '@/app/ui/songs/status';
import { formatDateToLocal, formatCurrency } from '@/app/lib/utils';
import { fetchFilteredSongs } from '@/app/lib/data';
import clsx from 'clsx';
import { Song } from '@/app/lib/definitions';

export default async function ShortSongsTable({
  query,
  currentPage,
  currentUser,
}: {
  query: string;
  currentPage: number;
  currentUser: number;
}) {
  const songs = await fetchFilteredSongs(query, currentPage);

  return (
    <div className="mt-6 flow-root">
      <div className="inline-block min-w-full align-middle">
        <div className="rounded-lg bg-gray-50 p-2 md:pt-0">
          <div className="md:hidden">
            {songs?.map((song : Song) => (
              <div
                key={song.sid}
                className="mb-2 w-full rounded-md bg-white p-4"
              >
                <div className="flex items-center justify-between border-b pb-4">
                  <div>
                    <div className="mb-2 flex items-center">
                      {/* <Image
                        src={song.cover_image_link}
                        className="mr-2 rounded-full"
                        width={28}
                        height={28}
                        alt={`${}'s profile picture`}
                      /> */}
                      <p>{song.song_name}</p>
                    </div>
                  </div>
                  {/* <InvoiceStatus status={invoice.status} /> */}
                </div>
                <div className="flex w-full items-center justify-between pt-4">
                  <div>
                    <p>{formatDateToLocal(song.date_added)}</p>
                  </div>
                  <div className="flex justify-end gap-2">
                    <PlaySong link={song.streaming_link.toString()} />
                    <DeleteSong id={song.sid.toString()} />
                  </div>
                </div>
              </div>
            ))}
          </div>
          <table className="hidden min-w-full text-gray-900 md:table">
            <thead className="rounded-lg text-left text-sm font-normal">
              <tr>
                <th scope="col" className="px-4 py-5 font-medium sm:pl-6">
                  Song
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Album
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Date Added
                </th>
                <th scope="col" className="relative py-3 pl-6 pr-3">
                  <span className="sr-only">Edit</span>
                </th>
              </tr>
            </thead>
            <tbody className="bg-white">
              {songs?.map((song) => (
                <tr
                  key={song.sid}
                  className="w-full border-b py-3 text-sm last-of-type:border-none [&:first-child>td:first-child]:rounded-tl-lg [&:first-child>td:last-child]:rounded-tr-lg [&:last-child>td:first-child]:rounded-bl-lg [&:last-child>td:last-child]:rounded-br-lg"
                >
                  <td className="whitespace-nowrap py-3 pl-6 pr-3">
                    <div className="flex items-center gap-3">
                      {/* <Image
                        src={invoice.image_url}
                        className="rounded-full"
                        width={28}
                        height={28}
                        alt={`${invoice.name}'s profile picture`}
                      /> */}
                      <p>{song.song_name}</p>
                    </div>
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {/* {formatCurrency(invoice.amount)} */}
                    Album
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {formatDateToLocal(song.date_added)}
                  </td>
                  {/* <td className="whitespace-nowrap px-3 py-3">
                    <InvoiceStatus status={invoice.status} />
                  </td> */}
                  <td className={clsx("whitespace-nowrap py-3 pl-6 pr-3", {"hidden" : song.artist_id === currentUser} )}>
                    <div className="flex justify-end gap-3">
                      <PlaySong link={song.streaming_link.toString()} />
                      <DeleteSong id={song.sid.toString()} />
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
